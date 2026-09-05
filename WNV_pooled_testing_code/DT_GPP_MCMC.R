
## -----------------------------
############################################################
## Packages
## Do not call installed.packages() inside MCMC simulation.
############################################################

pkgs <- c("MASS", "Matrix", "BayesLogit", "invgamma")

missing_pkgs <- pkgs[
  !vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_pkgs) > 0) {
  stop(
    paste0(
      "Missing required packages: ",
      paste(missing_pkgs, collapse = ", "),
      ". Please install them once before running this script."
    )
  )
}

suppressPackageStartupMessages({
  library(MASS)
  library(Matrix)
  library(BayesLogit)
  library(invgamma)
})
library(BayesLogit)
library(Matrix)
library(invgamma)
library(coda)

## -----------------------------
## 1) Settings following DT_GPP.R notation
## -----------------------------
if (!exists("df.DT_GPP")) stop("Please define df.DT_GPP before source('DT_GPP_WNV_one_run.R').")
if (!exists("fixed_formula_use")) fixed_formula_use <- ~ year_f + season_f

if (!exists("n.iter")) n.iter <- 500
if (!exists("burn.in")) burn.in <- floor(0.5 * n.iter)
if (!exists("thin")) thin <- 10
if (!exists("m")) m <- 30                          # number of predictive-process knots, same symbol as DT_GPP.R
if (!exists("knot.seed")) knot.seed <- 2026
if (!exists("mcmc.seed")) mcmc.seed <- 2026
if (!exists("update.ell")) update.ell <- TRUE
if (!exists("ell.sigma")) ell.sigma <- 0.10        # random-walk SD on log(ell)
if (!exists("verbose.every")) verbose.every <- 100
if (!exists("nugget")) nugget <- 1e-4
if (!exists("rpg.chunk.size")) rpg.chunk.size <- 200

set.seed(mcmc.seed)

## priors: keep names from DT_GPP.R
## DT_GPP.R uses a.sens=b.sens=a.spec=b.spec=1; here Se=Sp=1 are fixed because WNV has only pool-level test results.
a.sens <- 1
b.sens <- 1
a.spec <- 1
b.spec <- 1
sens <- 1
spec <- 1

a.sigma <- 1
b.sigma <- 1
a.l <- 1
b.l <- 1

## -----------------------------
## 2) Data objects in DT_GPP.R-style notation
## -----------------------------
df.DT_GPP <- as.data.frame(df.DT_GPP)
if (!all(c("T", "m", "x", "y") %in% names(df.DT_GPP))) {
  stop("df.DT_GPP must contain T, m, x, y.")
}

Z <- as.integer(df.DT_GPP$T)              # observed pool outcome
n.size <- as.integer(df.DT_GPP$m)         # pool sizes; DT_GPP.R uses n.size for pool size
n.pool <- length(Z)
if (any(is.na(Z)) || any(!Z %in% c(0L, 1L))) stop("T must be 0/1.")
if (any(is.na(n.size)) || any(n.size < 1)) stop("pool size m must be positive integers.")

X <- model.matrix(fixed_formula_use, data = df.DT_GPP)
n.b <- ncol(X)
b.cov <- diag(10, n.b)                   # same style as DT_GPP.R: b.cov <- diag(10, n.b)
b.prior.prec <- solve(b.cov)

loc.coordinates.raw <- as.matrix(df.DT_GPP[, c("x", "y")])
loc.center <- colMeans(loc.coordinates.raw, na.rm = TRUE)
loc.scale <- apply(loc.coordinates.raw, 2, sd, na.rm = TRUE)
loc.scale[loc.scale == 0] <- 1
loc.coordinates <- sweep(sweep(loc.coordinates.raw, 2, loc.center, "-"), 2, loc.scale, "/")

## -----------------------------
## 3) Predictive-process knots, distances, and covariance matrices
## -----------------------------
dist2_mat <- function(A, B) {
  A <- as.matrix(A)
  B <- as.matrix(B)
  A2 <- rowSums(A^2)
  B2 <- rowSums(B^2)
  D2 <- outer(A2, B2, "+") - 2 * tcrossprod(A, B)
  pmax(D2, 0)
}

loc.unique <- unique(as.data.frame(loc.coordinates))
loc.unique <- as.matrix(loc.unique)
m <- min(m, nrow(loc.unique))
set.seed(knot.seed)
id <- sample(seq_len(nrow(loc.unique)), size = m, replace = FALSE)
knot <- loc.unique[id, , drop = FALSE]

dist.c <- dist2_mat(loc.coordinates, knot)
dist.C <- dist2_mat(knot, knot)

## initial ell and sigma.sq, following the DT_GPP.R idea of initializing ell/sigma.sq
if (!exists("ell")) {
  d.tmp <- sqrt(dist.C[upper.tri(dist.C)])
  ell <- median(d.tmp[d.tmp > 0], na.rm = TRUE)
  if (!is.finite(ell) || ell <= 0) ell <- 0.5
}
ell.init <- ell
if (!exists("sigma.sq")) sigma.sq <- 0.5
sigma.sq.init <- sigma.sq

## Robust symmetric positive-definite solver.
## This is needed because GPP covariance matrices and the joint precision
## matrix can be extremely ill-conditioned for dense trap locations.
safe_chol <- function(A, base_jitter = 1e-8, max_try = 8) {
  A <- as.matrix(A)
  A <- (A + t(A)) / 2
  scale_A <- max(1, mean(diag(A), na.rm = TRUE))
  for (aa in 0:max_try) {
    jitter <- base_jitter * (10^aa) * scale_A
    R <- try(chol(A + diag(jitter, nrow(A))), silent = TRUE)
    if (!inherits(R, "try-error")) {
      return(list(R = R, jitter = jitter))
    }
  }
  stop("safe_chol failed even after adaptive jitter.")
}

solve_spd <- function(A, B = NULL, base_jitter = 1e-8) {
  sc <- safe_chol(A, base_jitter = base_jitter)
  R <- sc$R
  if (is.null(B)) {
    out <- chol2inv(R)
  } else {
    out <- backsolve(R, forwardsolve(t(R), B))
  }
  out
}

make_GPP_mats <- function(ell, sigma.sq) {
  ell <- max(as.numeric(ell), 1e-6)
  sigma.sq <- max(as.numeric(sigma.sq), 1e-8)
  C.prime <- exp(-dist.C / (2 * ell))
  C.prime <- C.prime + diag(nugget, m)
  C.mat <- sigma.sq * C.prime
  c.mat <- sigma.sq * exp(-dist.c / (2 * ell))
  ## A.mat = c.mat %*% solve(C.mat), computed without explicit solve().
  A.mat <- t(solve_spd(C.mat, t(c.mat), base_jitter = nugget))
  list(C.prime = C.prime, C.mat = C.mat, c.mat = c.mat, A.mat = A.mat)
}

GPP <- make_GPP_mats(ell, sigma.sq)
C.prime <- GPP$C.prime
C.mat <- GPP$C.mat
c.mat <- GPP$c.mat
A.mat <- GPP$A.mat

## -----------------------------
## 4) Helper functions for the DT pool-only observation model
## -----------------------------
clip_eta <- function(x, lower = -20, upper = 20) pmin(pmax(x, lower), upper)

## Safer wrapper for BayesLogit::rpg().
## Calling rpg() once on all 37k pools can trigger a C-level crash in some R/RStudio setups.
## Chunking keeps the DT_GPP.R Polya--Gamma step but reduces memory pressure.
rpg_safe <- function(h, z, chunk.size = 200) {
  h <- as.numeric(h)
  z <- as.numeric(z)
  n <- length(h)
  out <- numeric(n)
  starts <- seq.int(1L, n, by = chunk.size)
  for (st in starts) {
    en <- min(n, st + chunk.size - 1L)
    ii <- st:en
    zz <- clip_eta(z[ii], lower = -20, upper = 20)
    hh <- pmax(h[ii], 1e-8)
    tmp <- try(BayesLogit::rpg(length(ii), hh, zz), silent = TRUE)
    if (inherits(tmp, "try-error") || any(!is.finite(tmp))) {
      ## Emergency fallback to the PG mean E[PG(h,z)] = h/(2z)*tanh(z/2).
      ## This is used only if the C sampler fails for a chunk; it keeps the chain running for debugging.
      mu <- ifelse(abs(zz) < 1e-6, hh / 4, hh / (2 * zz) * tanh(zz / 2))
      tmp <- pmax(mu, 1e-8)
    }
    out[ii] <- as.numeric(tmp)
  }
  out[!is.finite(out) | out <= 0] <- 1e-8
  out
}

sample_trunc_binom_count <- function(size, prob) {
  ## sample K ~ Binomial(size, prob) | K >= 1
  if (size <= 0) return(0L)
  k <- seq_len(size)
  lp <- dbinom(k, size = size, prob = prob, log = TRUE)
  mx <- max(lp)
  w <- exp(lp - mx)
  sw <- sum(w)
  if (!is.finite(sw) || sw <= 0) return(1L)
  sample(k, size = 1L, prob = w / sw)
}

log_post_ell <- function(ell.value, b.value, xi.value, sigma.sq.value, w.value, kappa.value) {
  if (!is.finite(ell.value) || ell.value <= 0) return(-Inf)
  G <- make_GPP_mats(ell.value, sigma.sq.value)
  eta.value <- as.vector(X %*% b.value + G$A.mat %*% xi.value)
  eta.value <- clip_eta(eta.value)
  ## PG conditional likelihood kernel: sum kappa*eta - 0.5*w*eta^2
  ll.pg <- sum(kappa.value * eta.value - 0.5 * w.value * eta.value^2)
  Cprime.value <- G$C.prime
  chol.C <- try(chol(Cprime.value), silent = TRUE)
  if (inherits(chol.C, "try-error")) return(-Inf)
  logdet.C <- 2 * sum(log(diag(chol.C)))
  quad <- as.numeric(crossprod(xi.value, solve_spd(Cprime.value, xi.value, base_jitter = nugget)))
  lp.xi <- -0.5 * (m * log(sigma.sq.value) + logdet.C + quad / sigma.sq.value)
  lp.ell <- dgamma(ell.value, shape = a.l, rate = b.l, log = TRUE)
  ll.pg + lp.xi + lp.ell
}

## -----------------------------
## 5) Initialization
## -----------------------------
## initialize latent positive counts: K_j = 0 if negative, 1 if positive
Y.count <- ifelse(Z == 1L, 1L, 0L)

## initialize b by a rough binomial logistic model on latent counts; fall back to zeros if needed
b <- rep(0, n.b)
try({
  glm.init <- suppressWarnings(glm(cbind(Y.count, pmax(n.size - Y.count, 0)) ~ X - 1, family = binomial()))
  if (all(is.finite(coef(glm.init)))) b <- as.numeric(coef(glm.init))
}, silent = TRUE)

xi <- rep(0, m)

save.ind <- seq.int(burn.in + 1L, n.iter, by = thin)
n.save <- length(save.ind)
b.pred <- matrix(NA_real_, nrow = n.save, ncol = n.b)
colnames(b.pred) <- colnames(X)
xi.pred <- matrix(NA_real_, nrow = n.save, ncol = m)
sigma.sq.pred <- rep(NA_real_, n.save)
ell.pred <- rep(NA_real_, n.save)

p.sum <- rep(0, n.pool)
q.sum <- rep(0, n.pool)
Y.count.sum <- rep(0, n.pool)
save.count <- 0L
ell.accept <- 0L
ell.try <- 0L

## -----------------------------
## 6) MCMC sampler: DT_GPP.R-style GPP-MCMC adapted to WNV pool-only data
## -----------------------------
for (iter in seq_len(n.iter)) {
  eta <- as.vector(X %*% b + A.mat %*% xi)
  eta <- clip_eta(eta)
  p <- plogis(eta)
  q <- 1 - (1 - p)^n.size
  q <- pmin(pmax(q, 1e-12), 1 - 1e-12)
  
  ## Update latent positive counts K_j under pool-only DT observation
  Y.count[Z == 0L] <- 0L
  pos.ind <- which(Z == 1L)
  if (length(pos.ind) > 0) {
    for (jj in pos.ind) {
      Y.count[jj] <- sample_trunc_binom_count(n.size[jj], p[jj])
    }
  }
  
  ## Polya-Gamma augmentation for Binomial(n.size_j, p_j)
  kappa <- Y.count - n.size / 2
  w <- rpg_safe(n.size, eta, chunk.size = rpg.chunk.size)
  
  ## Joint Gaussian update for b and xi
  H <- cbind(X, A.mat)
  WH <- H * w
  prior.prec <- as.matrix(Matrix::bdiag(b.prior.prec, solve_spd(C.mat, base_jitter = nugget)))
  Q <- crossprod(H, WH) + prior.prec
  rhs <- crossprod(H, kappa)
  Q <- (Q + t(Q)) / 2
  ## Robust Gaussian update from precision Q.
  ## The previous direct solve(Q) can fail with "system is computationally singular".
  sc.Q <- safe_chol(Q, base_jitter = 1e-6)
  R.Q <- sc.Q$R
  mu <- as.vector(backsolve(R.Q, forwardsolve(t(R.Q), rhs)))
  ## Draw directly from N(mu, Q^{-1}) without explicitly forming Q^{-1}.
  ## If Q = R'R, then R^{-1} z has covariance Q^{-1}.
  z.draw <- rnorm(length(mu))
  theta.draw <- mu + backsolve(R.Q, z.draw)
  b <- theta.draw[seq_len(n.b)]
  xi <- theta.draw[n.b + seq_len(m)]
  
  ## Update sigma.sq from xi | ell
  Cprime.inv.xi <- solve_spd(C.prime, xi, base_jitter = nugget)
  quad.xi <- as.numeric(crossprod(xi, Cprime.inv.xi))
  sigma.sq <- invgamma::rinvgamma(1, shape = a.sigma + m / 2, rate = b.sigma + 0.5 * quad.xi)
  sigma.sq <- max(as.numeric(sigma.sq), 1e-8)
  
  ## Update ell by random-walk MH on log scale
  if (isTRUE(update.ell)) {
    ell.try <- ell.try + 1L
    log.ell.prop <- log(ell) + rnorm(1, 0, ell.sigma)
    ell.prop <- exp(log.ell.prop)
    lp.cur <- log_post_ell(ell, b, xi, sigma.sq, w, kappa)
    lp.prop <- log_post_ell(ell.prop, b, xi, sigma.sq, w, kappa)
    ## proposal is symmetric in log(ell), so add Jacobian term
    log.acc <- lp.prop - lp.cur + log.ell.prop - log(ell)
    if (is.finite(log.acc) && log(runif(1)) < log.acc) {
      ell <- ell.prop
      ell.accept <- ell.accept + 1L
    }
  }
  
  ## Rebuild GPP matrices after sigma.sq/ell update
  GPP <- make_GPP_mats(ell, sigma.sq)
  C.prime <- GPP$C.prime
  C.mat <- GPP$C.mat
  c.mat <- GPP$c.mat
  A.mat <- GPP$A.mat
  
  if (iter %in% save.ind) {
    save.count <- save.count + 1L
    eta.save <- as.vector(X %*% b + A.mat %*% xi)
    eta.save <- clip_eta(eta.save)
    p.save <- plogis(eta.save)
    q.save <- 1 - (1 - p.save)^n.size
    q.save <- pmin(pmax(q.save, 1e-12), 1 - 1e-12)
    
    b.pred[save.count, ] <- b
    xi.pred[save.count, ] <- xi
    sigma.sq.pred[save.count] <- sigma.sq
    ell.pred[save.count] <- ell
    p.sum <- p.sum + p.save
    q.sum <- q.sum + q.save
    Y.count.sum <- Y.count.sum + Y.count
  }
  
  if (verbose.every > 0 && iter %% verbose.every == 0) {
    cat("DT-GPP iter", iter, "/", n.iter,
        "| saved", save.count,
        "| sigma.sq", round(sigma.sq, 4),
        "| ell", round(ell, 4),
        "| ell acc", ifelse(ell.try > 0, round(ell.accept / ell.try, 3), NA),
        "\n")
  }
}

p.pred <- p.sum / save.count
q.pred <- q.sum / save.count
Y.count.pred <- Y.count.sum / save.count

DT_GPP_out <- list(
  p.pred = p.pred,
  q.pred = q.pred,
  Y.count.pred = Y.count.pred,
  b.pred = b.pred,
  b.post.mean = colMeans(b.pred),
  xi.pred = xi.pred,
  xi.post.mean = colMeans(xi.pred),
  sigma.sq.pred = sigma.sq.pred,
  sigma.sq.post.mean = mean(sigma.sq.pred),
  ell.pred = ell.pred,
  ell.post.mean = mean(ell.pred),
  ell.accept.rate = ifelse(ell.try > 0, ell.accept / ell.try, NA_real_),
  knot = knot,
  id = id,
  loc.center = loc.center,
  loc.scale = loc.scale,
  n.iter = n.iter,
  burn.in = burn.in,
  thin = thin,
  m = m,
  n.pool = n.pool,
  n.b = n.b,
  b.cov = b.cov,
  a.sens = a.sens,
  b.sens = b.sens,
  a.spec = a.spec,
  b.spec = b.spec,
  sens = sens,
  spec = spec,
  a.sigma = a.sigma,
  b.sigma = b.sigma,
  a.l = a.l,
  b.l = b.l,
  ell.sigma = ell.sigma,
  update.ell = update.ell,
  source_repository = "https://github.com/ileo0814/Group-Testing",
  source_script = "DT_GPP.R",
  adaptation_note = "DT_GPP.R-style Bayesian GPP-MCMC adapted to WNV pool-only outcomes; Se=Sp=1 fixed because no individual retesting/assay validation data are available."
)

cat("\n===== DT_GPP_out summary =====\n")
cat("n.pool =", DT_GPP_out$n.pool, "\n")
cat("m predictive-process knots =", DT_GPP_out$m, "\n")
cat("n.iter =", DT_GPP_out$n.iter, " burn.in =", DT_GPP_out$burn.in, " thin =", DT_GPP_out$thin, "\n")
cat("ell accept rate =", DT_GPP_out$ell.accept.rate, "\n")
print(summary(DT_GPP_out$p.pred))
print(summary(DT_GPP_out$q.pred))
print(DT_GPP_out$b.post.mean)

