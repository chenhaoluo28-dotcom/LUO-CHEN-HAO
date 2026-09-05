############################################################
## run_Huang_DT_GPP_WNV_v3.R
## Safer DT_GPP.R-style WNV runner.
## First run a tiny subset pilot to avoid RStudio fatal aborts.
############################################################

if (!exists("dat")) stop("Please load/prepare dat first.")
if (!all(c("T", "m", "x", "y") %in% names(dat))) stop("dat must contain T, m, x, y.")
if (!all(c("year_f", "season_f") %in% names(dat))) {
  if ("year" %in% names(dat)) dat$year_f <- factor(dat$year)
  if ("season" %in% names(dat)) dat$season_f <- factor(dat$season)
}
if (!all(c("year_f", "season_f") %in% names(dat))) stop("dat must contain year_f and season_f.")

fixed_formula_use <- ~ year_f + season_f
if (!dir.exists("outputs")) dir.create("outputs")

huang_settings <- data.frame(
  source_repository = "https://github.com/ileo0814/Group-Testing",
  source_script = "DT_GPP.R",
  protocol = "Dorfman testing / pooled testing GPP model",
  WNV_adaptation = "pool-only outcomes; no individual retesting results available",
  K_GPP_full = 100,
  knot_rule = "random sample of standardized observed unique trap locations",
  knot_seed = 2026,
  covariance_kernel = "squared exponential exp(-d^2/(2*ell)), following DT_GPP.R convention",
  n_iter_full = 15000,
  burn_in_full = 7500,
  thinning_full = 10,
  beta_prior = "beta ~ N(0, 10 I)",
  sigma2_prior = "sigma2 ~ Inverse-Gamma(shape=1, rate=1)",
  ell_prior = "ell ~ Gamma(shape=1, rate=1)",
  sensitivity_specificity = "Se=1, Sp=1 fixed for WNV baseline",
  mcmc_seed = 2026
)
print(huang_settings)
write.csv(huang_settings, "outputs/huang_DT_GPP_settings_to_report.csv", row.names = FALSE)

############################################################
## Switches
############################################################
RUN_TINY_SUBSET_PILOT <- FALSE
RUN_FULL_DATA_PILOT   <- TRUE
RUN_DTGPP_FULL        <- FALSE

############################################################
## 1) Tiny subset pilot: test the sampler and BayesLogit stability.
## This is NOT a thesis result.
############################################################
if (RUN_TINY_SUBSET_PILOT) {
  set.seed(2026)
  n.pos <- sum(dat$T == 1, na.rm = TRUE)
  n.neg <- sum(dat$T == 0, na.rm = TRUE)
  id.pos <- which(dat$T == 1)
  id.neg <- which(dat$T == 0)
  keep.pos <- sample(id.pos, min(400, length(id.pos)))
  keep.neg <- sample(id.neg, min(1600, length(id.neg)))
  keep <- sample(c(keep.pos, keep.neg))
  df.DT_GPP <- droplevels(dat[keep, ])
  fixed_formula_use <- ~ year_f + season_f
  n.iter <- 200
  burn.in <- 100
  thin <- 5
  m <- 20
  knot.seed <- 2026
  mcmc.seed <- 2026
  update.ell <- FALSE
  verbose.every <- 20
  nugget <- 1e-4
  rpg.chunk.size <- 100
  source("DT_GPP_WNV_one_run_v3.R")
  DT_GPP_tiny_pilot <- DT_GPP_out
  saveRDS(DT_GPP_tiny_pilot, "outputs/DT_GPP_WNV_tiny_pilot.rds")
}

############################################################
## 2) Full-data pilot: if tiny pilot works, set RUN_FULL_DATA_PILOT <- TRUE.
## This is still not the final thesis result.
############################################################
if (RUN_FULL_DATA_PILOT) {
  df.DT_GPP <- dat
  fixed_formula_use <- ~ year_f + season_f
  n.iter <- 500
  burn.in <- 250
  thin <- 10
  m <- 30
  knot.seed <- 2026
  mcmc.seed <- 2026
  update.ell <- FALSE
  verbose.every <- 50
  nugget <- 1e-4
  rpg.chunk.size <- 200
  source("DT_GPP_WNV_one_run_v3.R")
  DT_GPP_full_data_pilot <- DT_GPP_out
  saveRDS(DT_GPP_full_data_pilot, "outputs/DT_GPP_WNV_full_data_pilot.rds")
}

############################################################
## 3) Final full-data run: only after pilots work.
############################################################
if (RUN_DTGPP_FULL) {
  df.DT_GPP <- dat
  fixed_formula_use <- ~ year_f + season_f
  n.iter <- 15000
  burn.in <- 7500
  thin <- 10
  m <- 100
  knot.seed <- 2026
  mcmc.seed <- 2026
  update.ell <- TRUE
  ell.sigma <- 0.10
  verbose.every <- 500
  nugget <- 1e-4
  rpg.chunk.size <- 200
  source("DT_GPP_WNV_one_run_v3.R")
  DT_GPP_full <- DT_GPP_out
  saveRDS(DT_GPP_full, "outputs/DT_GPP_WNV_full.rds")
  write.csv(data.frame(p_hat_Huang_DT_GPP = DT_GPP_full$p.pred,
                       q_hat_Huang_DT_GPP = DT_GPP_full$q.pred),
            "outputs/DT_GPP_WNV_full_fitted_probabilities.csv",
            row.names = FALSE)
  write.csv(data.frame(term = names(DT_GPP_full$b.post.mean),
                       beta_post_mean = as.numeric(DT_GPP_full$b.post.mean)),
            "outputs/DT_GPP_WNV_beta_post_mean.csv",
            row.names = FALSE)
}
