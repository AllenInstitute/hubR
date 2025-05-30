#' @keywords internal
.argcheck.track.names = function(track.names, bigwigs){
    ##
    if(is.null(track.names)){
        track.names = unlist(lapply(strsplit(bigwigs, "-"), "[[", 1))
    }
    stopifnot(length(track.names) == length(bigwigs))
    return(track.names)
}

#' @keywords internal
.argcheck.track.labels = function(track.labels, bigwigs){
    ##
    if(is.null(track.labels)){
        track.labels = unlist(lapply(strsplit(bigwigs, "-"), "[[", 1))
    }
    stopifnot(length(track.labels) == length(bigwigs))
    return(track.labels)
}

#' @keywords internal
.argcheck.colors = function(colors, bigwigs){
    ## Safe color addition
    if(is.null(colors)){
        qual.cols = brewer.pal.info[brewer.pal.info$category == 'qual',]
        pal.colors = unlist(mapply(brewer.pal, qual.cols$maxcolors, rownames(qual.cols)))
        if(length(bigwigs) <= length(pal.colors)){
            colors = pal.colors[1:length(bigwigs)]
        }else{
            print("WARNING -- To many tracks, reusing colors. Consider supplying your own color vector.")
            colors = sample(pal.colors, length(bigwigs), replace=TRUE)
        }
    }
    stopifnot(length(colors) == length(bigwigs))
    return(colors)
}

#' @keywords internal
.argcheck.groupby = function(groupby, bigwigs){
    if(is.null(groupby)){
        groupby = 1:length(bigwigs)
    }
    return(groupby)
}

#' @keywords internal
.argcheck.bigwigs = function(data.dir, bigwigs){
    ## Get bigwig file names, the order of this vector dictates track orders
    if(is.null(bigwigs)){
        bigwigs = list.files(data.dir, pattern='*.bw')
        if(length(bigwigs) == 0){ stop("Cannot find any bigwigs (*.bw) at data directory.") }
    }else{
        ## Check that all supplied bigwig files exist
        if(all(file.exists(bigwigs)) == FALSE){ stop("Cannot find all bigwigs. Check name/path.") }
    }
    return(bigwigs)
}

#' @keywords internal
.argcheck.bucket.names = function(bucket.name, bad.chars = c("\\~", "\\`", "\\!", "\\@", '\\#', '\\$', '\\%', '\\^', '\\&', '\\*', '\\|', '\\:', '\\;', '\\,', '\\.', "\\|", "\\_")){
    if(grepl(paste(bad.chars, collapse="|"), bucket.name) | nchar(bucket.name) == 0){
        print(paste0("Invalid character in: ", bucket.name))
        stop("Bucket names should be all lower case and only contain '-'")
    }
    bucket.name = gsub('^\\/|\\/$', '', bucket.name)
    return(bucket.name)
}
