library(rstan)
library(bayesplot)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
stan_code <- '
  data {
    int<lower=0> J;         // number of schools
    real y[J];              // estimated treatment effects
    real<lower=0> sigma[J]; // standard error of effect estimates
  }
  parameters {
    real mu;                // population treatment effect
    real<lower=0> tau;      // standard deviation in treatment effects
    vector[J] eta;          // unscaled deviation from mu by school
  }
  transformed parameters {
    vector[J] theta = mu + tau * eta;        // school treatment effects
  }
  model {
    target += normal_lpdf(eta | 0, 1);       // prior log-density
    target += normal_lpdf(y | theta, sigma); // log-likelihood
  }
'

schools <- list(
  J = 8,
  y = c(28,  8, -3,  7, -1,  1, 18, 12),
  sigma = c(15, 10, 16, 11,  9, 11, 10, 18)
)

# takes a while to run: majority spent compiling the model
fit <- stan(model_code = stan_code, data = schools)
summary(fit)

cbind(
  school = LETTERS[1:8],
  as.data.frame(schools[c("y", "sigma")])
)

mcmc_areas(as.array(fit), regex_pars = "theta")
ggsave(here::here("8schools-posteriors.png"), h = 7, w = 6, s = 0.6)
