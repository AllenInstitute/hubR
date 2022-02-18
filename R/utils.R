#' @keywords internal
.argcheck.pseudo.names = function(pseudo.names, bigwigs){
    ##
    if(is.null(pseudo.names)){
        pseudo.names = unlist(lapply(strsplit(bigwigs, "-"), "[[", 1))
    }
    stopifnot(length(pseudo.names) == length(bigwigs))
    return(pseudo.names)
}

#' @keywords internal
.argcheck.long.labels = function(long.labels, bigwigs){
    ##
    if(is.null(long.labels)){
        long.labels = unlist(lapply(strsplit(bigwigs, "-"), "[[", 1))
    }
    stopifnot(length(long.labels) == length(bigwigs))
    return(long.labels)
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
            colors = sample(pal.colors, length(bigwigs))
        }
    }
    stopifnot(length(colors) == length(bigwigs))
    return(colors)
}

#' @keywords internal
.argcheck.bucket.names = function(bucket.name, bad.chars = c("\\~", "\\`", "\\!", "\\@", '\\#', '\\$', '\\%', '\\^', '\\&', '\\*', '\\|', '\\:', '\\;', '\\,', '\\.', "\\|", "\\_")){
    if(grepl(paste(bad.chars, collapse="|"), bucket.name) | nchar(bucket.name) == 0){
        print(paste0("Invalid character in: ", bucket.name))
        stop("Bucket names should be all lower case and only contain '-'")
    }
    bucket.name = tolower(bucket.name)
    return(bucket.name)
}