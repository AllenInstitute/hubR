#' Build multi-wig track hub
#'
#' This function ..
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param bw.df Data.frame holding all bigwig and track information supplied by user.
#' @param anno.df Data.frame holding all data level information supplied by user.
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return A matrix of the infile
#' @keywords internal
generate.multiwig.track.hub = function(track.bucket, 
                                        bw.df,
                                        anno.df,
                                        output.track.file, 
                                        email){
    
    ## Define some helpful labels
    shortLabel = paste(anno.df$region, anno.df$type, sep=" ")
    longLabel  = paste(anno.df$region, anno.df$type, anno.df$taxonomy, sep=" ")

    ## Open track hub file
    fileConnection = file(output.track.file, open="w+")

    ## Hub header
    writeLines(paste0("hub ", anno.df$species, anno.df$region, anno.df$type, " Hub"), fileConnection)
    writeLines(paste0("shortLabel ", shortLabel, " Hub"), fileConnection)
    writeLines(paste0("longLabel ", longLabel, " Hub"), fileConnection)
    writeLines(paste0("useOneFile on"), fileConnection)
    writeLines(paste0("email ", email), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Genome info
    writeLines(paste0("genome ", anno.df$genome), fileConnection)
    writeLines(paste0(""), fileConnection)

    # Multiwig header
    writeLines(paste0("track ", species, anno.df$region, anno.df$type, anno.df$taxonomy), fileConnection)
    writeLines(paste0("container multiWig"), fileConnection)
    writeLines(paste0("shortLabel ", anno.df$region, anno.df$type), fileConnection)
    writeLines(paste0("longLabel ", anno.df$region, anno.df$type, taxonomy, " tracks"), fileConnection)
    writeLines(paste0("type bigWig"), fileConnection)
    writeLines(paste0("aggregate none"), fileConnection)
    writeLines(paste0("showSubtrackColorOnUi on"), fileConnection)
    writeLines(paste0("visibility full"), fileConnection)
    writeLines(paste0("autoScale on"), fileConnection)
    writeLines(paste0("alwaysZero on"), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Track writing
    for(bw.itr in 1:nrow(bw.df)){
        writeLines(paste0("\ttrack ", bw.df$track.name[bw.itr]), fileConnection)
        writeLines(paste0("\tbigDataUrl https://s3-us-west-2.amazonaws.com/", track.bucket, "/", bw.df$bigwigs[bw.itr], "?AWSAccessKeyId=", Sys.getenv("AWS_ACCESS_KEY_ID"), "&Expires=2147483647&Signature=", bw.df$hmac.encoded[bw.itr]), fileConnection)
        writeLines(paste0("\tparent ", anno.df$species, anno.df$region, anno.df$type, anno.df$taxonomy), fileConnection)
        writeLines(paste0("\tshortLabel ", bw.df$track.names[bw.itr]), fileConnection)
        writeLines(paste0("\tlongLabel ", bw.df$track.labels[bw.itr]), fileConnection)
        writeLines(paste0("\ttype bigWig"), fileConnection)
        writeLines(paste0("\tvisibility full"), fileConnection)
        writeLines(paste0("\tautoscale on"), fileConnection)
        writeLines(paste0("\tcolor ", paste(col2rgb(bw.df$colors[bw.itr])[,1], collapse=",")), fileConnection)
        writeLines(paste0("\talwaysZero on"), fileConnection)
        writeLines(paste0("\tmaxHeightPixels 100:40:8"), fileConnection)
        writeLines(paste0("\tpriority ", bw.itr), fileConnection)
        writeLines(paste0(""), fileConnection)
    }

    close(fileConnection)
}

#' Build composite track hub
#'
#' This function..
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param bw.df Data.frame holding all bigwig and track information supplied by user.
#' @param anno.df Data.frame holding all data level information supplied by user.
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return A matrix of the infile
#' @keywords internal
generate.composite.track.hub = function(track.bucket, 
                                        bw.df,
                                        anno.df,
                                        output.track.file, 
                                        email){
    
    # ## Define some helpful labels
    # shortLabel = paste(bw.df$region, type, sep=" ")
    # longLabel  = paste(bw.df$region, type, taxonomy, sep=" ")

    # ## Open track hub file
    # fileConnection = file(output.track.file, open="w+")

    # ## Shub header
    # writeLines(paste0("hub ", species, bw.df$region, type, " Hub"), fileConnection)
    # writeLines(paste0("shortLabel ", shortLabel, " Hub"), fileConnection)
    # writeLines(paste0("longLabel ", longLabel, " Hub"), fileConnection)
    # writeLines(paste0("useOneFile on"), fileConnection)
    # writeLines(paste0("email ", email), fileConnection)
    # writeLines(paste0(""), fileConnection)

    # ## Genome info
    # writeLines(paste0("genome ", genome), fileConnection)
    # writeLines(paste0(""), fileConnection)

    # # Multiwig header
    # writeLines(paste0("track ", species, bw.df$region, type, taxonomy), fileConnection)
    # writeLines(paste0("container multiWig"), fileConnection)
    # writeLines(paste0("shortLabel ", bw.df$region, type), fileConnection)
    # writeLines(paste0("longLabel ", bw.df$region, type, taxonomy, " tracks"), fileConnection)
    # writeLines(paste0("type bigWig"), fileConnection)
    # writeLines(paste0("aggregate none"), fileConnection)
    # writeLines(paste0("showSubtrackColorOnUi on"), fileConnection)
    # writeLines(paste0("visibility full"), fileConnection)
    # writeLines(paste0("autoScale on"), fileConnection)
    # writeLines(paste0("alwaysZero on"), fileConnection)
    # writeLines(paste0(""), fileConnection)

    # ## Track writing
    # for(bw.itr in 1:length(bigwigs)){
    #     writeLines(paste0("\ttrack ", track.names[bw.itr]), fileConnection)
    #     writeLines(paste0("\tbigDataUrl https://s3-us-west-2.amazonaws.com/", track.bucket, "/", bigwigs[bw.itr], "?AWSAccessKeyId=", Sys.getenv("AWS_ACCESS_KEY_ID"), "&Expires=2147483647&Signature=", hmac.encoded[bw.itr]), fileConnection)
    #     writeLines(paste0("\tparent ", species, bw.df$region, type, taxonomy), fileConnection)
    #     writeLines(paste0("\tshortLabel ", track.names[bw.itr]), fileConnection)
    #     writeLines(paste0("\tlongLabel ", track.labels[bw.itr]), fileConnection)
    #     writeLines(paste0("\ttype bigWig"), fileConnection)
    #     writeLines(paste0("\tvisibility full"), fileConnection)
    #     writeLines(paste0("\tautoscale on"), fileConnection)
    #     writeLines(paste0("\tcolor ", paste(col2rgb(colors[bw.itr])[,1], collapse=",")), fileConnection)
    #     writeLines(paste0("\talwaysZero on"), fileConnection)
    #     writeLines(paste0("\tmaxHeightPixels 100:40:8"), fileConnection)
    #     writeLines(paste0("\tpriority ", bw.itr), fileConnection)
    #     writeLines(paste0(""), fileConnection)
    # }
    # close(fileConnection)
}

#' Build SEA-AD style multi-wig track hub
#'
#' This function ..
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param bw.df Data.frame holding all bigwig and track information supplied by user.
#' @param anno.df Data.frame holding all data level information supplied by user.
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return A matrix of the infile
#' @keywords internal
generate.sea.ad.track.hub = function(track.bucket, 
                                        bw.df,
                                        anno.df,
                                        output.track.file, email,
                                        aggregate="stacked"){
    
    ## Define some helpful labels
    shortLabel = paste(anno.df$region, anno.df$type, sep=" ")
    longLabel  = paste(anno.df$region, anno.df$type, anno.df$taxonomy, sep=" ")

    ## Open track hub file
    fileConnection = file(output.track.file, open="w+")

    ## Hub header
    writeLines(paste0("hub ", anno.df$species, anno.df$region, anno.df$type, " Hub"), fileConnection)
    writeLines(paste0("shortLabel ", shortLabel, " Hub"), fileConnection)
    writeLines(paste0("longLabel ", longLabel, " Hub"), fileConnection)
    writeLines(paste0("useOneFile on"), fileConnection)
    writeLines(paste0("email ", email), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Genome info
    writeLines(paste0("genome ", anno.df$genome), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Priority
    priority = 1

    ## Build celltype multiwig containers
    for(anno in unique(bw.df$groupby)){

        ## Multiwig ID
        multiwig.id = gsub(" ", "", anno) #paste0(paste(anno.df$species, anno.df$region, anno.df$type, anno.df$taxonomy, sep="_"), gsub(" ", "", anno))

        ## Multiwig header
        writeLines(paste0("track ", multiwig.id), fileConnection)
        writeLines(paste0("container multiWig"), fileConnection)
        writeLines(paste0("shortLabel ", multiwig.id), fileConnection)
        writeLines(paste0("longLabel ", multiwig.id, " tracks"), fileConnection)
        writeLines(paste0("type bigWig"), fileConnection)
        writeLines(paste0("aggregate ", aggregate), fileConnection)
        writeLines(paste0("showSubtrackColorOnUi on"), fileConnection)
        writeLines(paste0("visibility full"), fileConnection)
        writeLines(paste0("autoScale on"), fileConnection)
        writeLines(paste0("alwaysZero on"), fileConnection)
        writeLines(paste0(""), fileConnection)

        ## Identify bigwigs that correspond to annotation level, colors is assumed to be a named vector indexed by bigwig full name.
        anno.bigwigs = bw.df[bw.df$groupby == anno,]
        for(bw.itr in 1:nrow(anno.bigwigs)){
            ## Track writing
            writeLines(paste0("\ttrack ", anno.bigwigs$track.name[bw.itr]), fileConnection)
            writeLines(paste0("\tbigDataUrl https://s3-us-west-2.amazonaws.com/", track.bucket, "/", anno.bigwigs$bigwig[bw.itr], "?AWSAccessKeyId=", Sys.getenv("AWS_ACCESS_KEY_ID"), "&Expires=2147483647&Signature=", anno.bigwigs$hmac.encoded[bw.itr]), fileConnection)
            writeLines(paste0("\tparent ", multiwig.id), fileConnection)
            writeLines(paste0("\tshortLabel ", anno.bigwigs$track.name[bw.itr]), fileConnection)
            writeLines(paste0("\tlongLabel ", anno.bigwigs$track.label[bw.itr]), fileConnection)
            writeLines(paste0("\ttype bigWig"), fileConnection)
            writeLines(paste0("\tvisibility full"), fileConnection)
            writeLines(paste0("\tautoscale on"), fileConnection)
            writeLines(paste0("\tcolor ", paste(col2rgb(anno.bigwigs$colors[bw.itr])[,1], collapse=",")), fileConnection)
            writeLines(paste0("\talwaysZero on"), fileConnection)
            writeLines(paste0("\tmaxHeightPixels 40:40:40"), fileConnection)
            writeLines(paste0("\tpriority ", priority), fileConnection)
            writeLines(paste0(""), fileConnection)
            priority = priority+1
        }
    }
    close(fileConnection)
}

