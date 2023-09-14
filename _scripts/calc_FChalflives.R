# library(ggplot2)
# library(minpack.lm)

## Function to create the plot for the half-life time per runid for a given dataframe of channels over time
plot_hlt = function(df){
  ## loop through each runid seperately
  for (i in seq(1, length(unique(df$run_id)))){
    
    ## select only those rows with a specific runid
    run = unique(df$run_id)[i]
    print(run)
    run_df = df[which(df$run_id==run),]
    
    ## adapt some naming schemes
    run_df$X = NULL
    run_df$run_id = NULL
    colnames(run_df) = c("channels", "time")
    run_df = run_df[,c(2,1)]
    
    ## exclude runs with too few data points
    if(dim(run_df)[1]<10){
      next
    }
    
    tryCatch(
      expr = {
        ## Model building
        if(min(run_df$channels)<10){
          run_df = run_df[c(1:min(which(run_df$channels<10))),]    # use only data until first time less than 10 channels
        }
        model = nls(channels ~ SSlogis(time, a, b, c), data = run_df, control = nls.control(warnOnly = TRUE))
        # summary(model)
        # lines(run_df$time, predict(model), lwd =2, col = "red") 
        
        ## Open the png output stream and plot data points
        png(paste("plots/", run, "_hlt.png", sep = ""))
        plot(run_df)
        
        ## Extract the coefficients from the model
        a = coef(model)[1]
        b = coef(model)[2]
        c = coef(model)[3]
        
        ## Formula behind the model
        y = a/(1+exp((b-run_df$time)/c))
        lines(run_df$time, y, col = "blue", lwd =2)   # plot the fitted curve 
        
        ## Target value = half of the max number of channels -> half-life
        target_y <- max(run_df$channels)/2
        ## Define the interval where you want to search for a root -> chose 72h as normal run time
        # interval <- c(0, max(run_df$time))
        interval <- c(0, 72*60*60)
        ## Define the function that was used
        f = function(x) a/(1+exp((b-x)/c))
        ## Use uniroot to find the root of the function within the interval
        result <- uniroot(function(x) f(x) - target_y, interval = interval)
        
        ## Calculate and plot the half-life time 
        fcHalfLife = result$root
        abline(v = fcHalfLife)
        
        dev.off()
      }, 
      error = function(e) {
        message("Got an error message for:")
        message(run)
        message("Here's the original error message:")
        message(e)
        png(paste("error_plots/", run, ".png", sep = ""))
        plot(run_df, main = run)
        dev.off()
        png(paste("error_plots/", run, "_zoomout.png", sep = ""))
        plot(run_df, xlim = c(0, 72*60*60), ylim = c(0,520), main = run)
        dev.off()
      }
    )
  }
}

## Function to create the plot for the half-life time per runid for a given dataframe of channels over time
plot_hlt_complete = function(df){
  ## loop through each runid seperately
  for (i in seq(1, length(unique(df$run_id)))){
    
    ## select only those rows with a specific runid
    run = unique(df$run_id)[i]
    print(run)
    run_df = df[which(df$run_id==run),]
    
    ## adapt some naming schemes
    run_df$X = NULL
    run_df$run_id = NULL
    colnames(run_df) = c("channels", "time")
    run_df = run_df[,c(2,1)]
    
    ## exclude runs with too few data points
    if(dim(run_df)[1]<10){
      next
    }
    
    tryCatch(
      expr = {
        ## Model building
        if(min(run_df$channels)<10){
          run_df = run_df[c(1:min(which(run_df$channels<10))),]    # use only data until first time less than 10 channels
        }
        model = nls(channels ~ SSlogis(time, a, b, c), data = run_df, control = nls.control(warnOnly = TRUE))
        # summary(model)
        # lines(run_df$time, predict(model), lwd =2, col = "red") 
        
        ## Open the png output stream and plot data points
        png(paste("plots_zoomOut/", run, "_hlt.png", sep = ""))
        plot(run_df, xlim = c(0, 72*60*60), ylim = c(0,520))
        
        ## Extract the coefficients from the model
        a = coef(model)[1]
        b = coef(model)[2]
        c = coef(model)[3]
        
        ## Formula behind the model
        x = seq(0, 72*60*60, 1000)
        y = a/(1+exp((b-x)/c))
        lines(x, y, col = "blue", lwd =2)   # plot the fitted curve 
        
        ## Target value = half of the max number of channels -> half-life
        target_y <- max(run_df$channels)/2
        ## Define the interval where you want to search for a root -> chose 72h as normal run time
        # interval <- c(0, max(run_df$time))
        interval <- c(0, 72*60*60)
        ## Define the function that was used
        f = function(x) a/(1+exp((b-x)/c))
        ## Use uniroot to find the root of the function within the interval
        result <- uniroot(function(x) f(x) - target_y, interval = interval)
        
        ## Calculate and plot the half-life time 
        fcHalfLife = result$root
        abline(v = fcHalfLife)
        
        dev.off()
      }, 
      error = function(e) {
        message("Got an error message for:")
        message(run)
        message("Here's the original error message:")
        message(e)
        png(paste("error_plots/", run, ".png", sep = ""))
        plot(run_df, main = run)
        dev.off()
        png(paste("error_plots/", run, "_zoomout.png", sep = ""))
        plot(run_df, xlim = c(0, 72*60*60), ylim = c(0,520), main = run)
        dev.off()
      }
    )
  }
}

## Function to create the plot for the half-life time per runid for a given dataframe of channels over time
extract_hlt = function(df){
  ## preallocate list space
  runids = rep("NA", length(unique(df$run_id)))
  hlt = rep("NA", length(unique(df$run_id)))
  
  ## loop through each runid seperately
  for (i in seq(1, length(unique(df$run_id)))){
    
    ## select only those rows with a specific runid
    run = unique(df$run_id)[i]
    run_df = df[which(df$run_id==run),]
    
    runids[i] = run
    
    ## adapt some naming schemes
    run_df$X = NULL
    run_df$run_id = NULL
    colnames(run_df) = c("channels", "time")
    run_df = run_df[,c(2,1)]
    
    ## exclude runs with too few data points
    if(dim(run_df)[1]<10){
      next
    }
    
    ## Try to build the model and extract the half-life time
    tryModel <- tryCatch(
      expr = {
        ## Model building
        if(min(run_df$channels)<10){
          run_df = run_df[c(1:min(which(run_df$channels<10))),]    # use only data until first time less than 10 channels
        }
        model = nls(channels ~ SSlogis(time, a, b, c), data = run_df, control = nls.control(warnOnly = TRUE))
        # summary(model)

        ## Extract the coefficients from the model
        a = coef(model)[1]
        b = coef(model)[2]
        c = coef(model)[3]
        
        ## Target value = half of the max number of channels -> half-life
        target_y <- max(run_df$channels)/2
        ## Define the interval where you want to search for a root -> chose 72h as normal run time
        interval <- c(0, 72*60*60)
        ## Define the function that was used
        f = function(x) a/(1+exp((b-x)/c))
        ## Use uniroot to find the root of the function within the interval
        result <- uniroot(function(x) f(x) - target_y, interval = interval)
        
        ## Calculate and plot the half-life time 
        fcHalfLife = result$root
        hlt[i] = fcHalfLife
      }, 
      error = function(e) {
        message("Got an error message for:")
        message(run)
      }
    )
  }
  res = data.frame(runids = unlist(runids), hlt = unlist(hlt))
  return(res)
}


## Load the dataset
setwd("/run/user/1000/gvfs/sftp:host=gsuffa.bioinf.uni-jena.de,user=nu36par/data/dessertlocal/bitsNpieces_ONT/fc_halfLife/")
df = read.table("all_data.csv", sep = ",", header = TRUE)

## extract and store the half-life times to the runids
hlts = extract_hlt(df)
write.table(hlts, "halflifetimes.txt", quote = FALSE, row.names = FALSE)

## plot the data with model fit and half-life time
plot_hlt(df)
plot_hlt_complete(df)
################################################################################
## Check for half-life time = NA
################################################################################

## Check for those runs for which the half life time could not be calculated
no_hlt = hlts[which(hlts$hlt == "NA"),1]
no_hlt_df = df[which(df$run_id %in% no_hlt),]


length(unique(no_hlt_df$run_id))

runids = c()
hlts = c()


for (i in seq(1, length(unique(no_hlt_df$run_id)))){
  run = unique(no_hlt_df$run_id)[i]
  runids[i] = run
  run_df = no_hlt_df[which(no_hlt_df$run_id==run),]
  png(paste("polynomial_plots/", run, ".png", sep = ""))
  plot(run_df$seconds_since_start_of_run, run_df$n_channels, main = run, xlim = c(0, 72*60*60), ylim = c(0,520))
  
  x = seq(0, 72*60*60, 1000)
  
  fit1 <- lm(n_channels~poly(seconds_since_start_of_run,2,raw=TRUE), data=run_df)
  lines(seq(0, 72*60*60, 1000), predict(fit1, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='green')
  model <- lm(n_channels~poly(seconds_since_start_of_run,3,raw=TRUE), data=run_df)
  lines(seq(0, 72*60*60, 1000), predict(model, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='red')
  fit3 <- lm(n_channels~poly(seconds_since_start_of_run,4,raw=TRUE), data=run_df)
  lines(seq(0, 72*60*60, 1000), predict(fit3, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='purple')
  fit4 <- lm(n_channels~poly(seconds_since_start_of_run,5,raw=TRUE), data=run_df)
  lines(seq(0, 72*60*60, 1000), predict(fit4, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='blue')
  
  ## Extract the coefficients from the model
  a = coef(model)[1]
  b = coef(model)[2]
  c = coef(model)[3]
  d = coef(model)[4]
  
  ## Try to build the model and extract the half-life time
  tryModel <- tryCatch(
    expr = {
      ## Target value = half of the max number of channels -> half-life
      target_y <- max(run_df$n_channels)/2
      ## Define the interval where you want to search for a root -> chose 72h as normal run time
      interval <- c(0, 72*60*60)
      ## Define the function that was used
      f = function(x) a+b*x+c*x^2+d*x^3
      ## Use uniroot to find the root of the function within the interval
      result <- uniroot(function(x) f(x) - target_y, interval = interval)
      
      ## Calculate and plot the half-life time 
      fcHalfLife = result$root
      abline(v = fcHalfLife)
      hlts[i] = fcHalfLife
    }, 
    error = function(e) {
      message("Got an error message for:")
      message(run)
    }
  )
  dev.off()
}

polynom_runids = data.frame(runids, hlts)



## one weird example
run = "4fdc08092e44d4f24cf95d1268730d81f5f5b615"
run_df = no_hlt_df[which(no_hlt_df$run_id==run),]
plot(run_df$seconds_since_start_of_run, run_df$n_channels, main = run, xlim = c(0, 72*60*60), ylim = c(0,520))

x = seq(0, 72*60*60, 1000)

fit1 <- lm(n_channels~poly(seconds_since_start_of_run,2,raw=TRUE), data=run_df)
lines(seq(0, 72*60*60, 1000), predict(fit1, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='green')
model <- lm(n_channels~poly(seconds_since_start_of_run,3,raw=TRUE), data=run_df)
lines(seq(0, 72*60*60, 1000), predict(model, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='red')
fit3 <- lm(n_channels~poly(seconds_since_start_of_run,4,raw=TRUE), data=run_df)
lines(seq(0, 72*60*60, 1000), predict(fit3, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='purple')
fit4 <- lm(n_channels~poly(seconds_since_start_of_run,5,raw=TRUE), data=run_df)
lines(seq(0, 72*60*60, 1000), predict(fit4, data.frame(seconds_since_start_of_run = seq(0, 72*60*60, 1000))), col='blue')

## Extract the coefficients from the model
a = coef(model)[1]
b = coef(model)[2]
c = coef(model)[3]
d = coef(model)[4]
## Target value = half of the max number of channels -> half-life
target_y <- max(run_df$n_channels)/2
## Define the interval where you want to search for a root -> chose 72h as normal run time
interval <- c(0, 30000)
## Define the function that was used
f = function(x) a+b*x+c*x^2+d*x^3
## Use uniroot to find the root of the function within the interval
result <- uniroot(function(x) f(x) - target_y, interval = interval)

## Calculate and plot the half-life time 
fcHalfLife = result$root
abline(v = fcHalfLife)






################################################################################
## Run without using the function
################################################################################

## Load the dataset
setwd("/run/user/1000/gvfs/sftp:host=gsuffa.bioinf.uni-jena.de,user=nu36par/data/dessertlocal/bitsNpieces_ONT/fc_halfLife/")
df = read.table("all_data.csv", sep = ",", header = TRUE)

run = "728c58ecd752a402f4b635910852998faaa29c00"
df = df[which(df$run_id==run),]
df$X = NULL
df$run_id = NULL
colnames(df) = c("channels", "time")
df = df[,c(2,1)]

## Build the plot basis
plot(df, main = run)
plot(df, xlim = c(0, 72*60*60), ylim = c(0,520), main = run)

## Use only data until forst time under 10 channels for the model
if(min(df$channels)<10){
  df = df[c(1:min(which(df$channels<10))),]
}

dim(df)
df = df[c(1:dim(df)[1]-1),]

## Build a model 
model = nls(channels ~ SSlogis(time, a, b, c), data = df, trace = TRUE, control = nls.control(warnOnly = TRUE))
# summary(model)
lines(df$time, predict(model), lwd =2, col = "red")

## Values for formula from model coefficients
################################################################################
## Extract the coefficients from the model
a = coef(model)[1]
b = coef(model)[2]
c = coef(model)[3]

# build the formula
y = a/(1+exp((b-df$time)/c))
lines(df$time, y, col = "blue", lwd =2)


## Extract the half-life time
#################################################################################
## Target value = half of the max number of channels -> half-life
target_y <- max(df$channels)/2
## Define the interval where you want to search for a root -> chose 72h as normal run time
# interval <- c(0, max(df$time))
interval <- c(0, 72*60*60)
## Define the function that was used
f = function(x) a/(1+exp((b-x)/c))
## Use uniroot to find the root of the function within the interval
result <- uniroot(function(x) f(x) - target_y, interval = interval)

## Calculate and plot half-life time
fcHalfLife = result$root
abline(v = fcHalfLife)

