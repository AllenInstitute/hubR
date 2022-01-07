#' Builds a track hub for the UCSC genome browser
#'
#' This function takes in a vector of bigwig file names along associated metadata and Amazon S3 credentials.
#' It assumes the user has created an S3 bucket 'track.bucket' where the bigwig files will be accessible on S3.
#' Any changes to the bigwig file names or 'track.bucket' will require the regeneration of HMAC signatures and the hub file.
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param access.key Amazon S3 access key ID
#' @param secret.key Amazon S3 secret access key
#' @param bigwigs Bigwig file names which exactly match those in 'track.bucket'
#' @param pseudo.names  Short labels to give each track. If NULL the function attemps to gather from .bw file name: pseudo.names-*.bw
#' @param long.labels Detailed labels to give each track. If NULL the function attemps to gather from .bw file name: long.labels-*.bw
#' @param colors Colors (in R, G, B format) to give the tracks. If NULL colors will be auto-generated.
#' @param species Species information
#' @param region Brain region information
#' @param type Data type (ATAC, Multiome, etc.)
#' @param cluster Cluster label information
#' @param genome Genome information
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @export
hubR = function(track.bucket, access.key, secret.key,
                bigwigs, pseudo.names=NULL, long.labels=NULL, colors=NULL, 
                species, region, type, cluster, genome,
                output.track.file="trackDB.txt", email=""){

    ## Argument checking and generation if not provided
    pseudo.names = .argcheck.pseudo.names(pseudo.names, bigwigs)
    long.labels  = .argcheck.long.labels(long.labels, bigwigs)
    colors       = .argcheck.colors(colors, bigwigs)

    ## Compute hmac signatures using sha1
    hmac.encoded = create.signatures(track.bucket, secret.key, bigwigs)

    ## Write out the hub file
    generate.track.hub(output.track.file, 
                        genome, species, region, type, cluster,
                        bigwigs, hmac.encoded, pseudo.names, long.labels, colors, email)

}

#' Computes HMAC signatures
#'
#' This function takes in a vector of bigwig file names and Amazon S3 credentials to generate hmac signatures to access .bw files.
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param secret.key Amazon S3 secret access key
#' @param bigwigs Bigwig file names which exactly match those in 'track.bucket'
#'
#' @export
create.signatures = function(track.bucket, secret.key, bigwigs){
    ## URL encode takes the hmac string and converts '=' and other special characters to %-encoded characters
    ## Following original conventions with respect to sha1
    hmac.encoded = sapply(bigwigs, function(x) URLencode(base64Encode(hmac(secret.key, paste0("GET\n\n\n2147483647\n/", track.bucket, "-tracks/", x), "sha1", raw=TRUE)), reserved=TRUE))
    return(hmac.encoded)
}

#' Build multi-wig track hub
#'
#' This function loads a file as a matrix. It assumes that the first column
#' contains the rownames and the subsequent columns are the sample identifiers.
#' Any rows with duplicated row names will be dropped with the first one being
#' kepted.
#'
#' @param hmac.encoded Bigwig file signatures computed with `create.signatures`
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param access.key Amazon S3 access key ID
#' @param bigwigs Bigwig file names which exactly match those in 'track.bucket'
#' @param pseudo.names  Short labels to give each track. If NULL the function attemps to gather from .bw file name: pseudo.names-*.bw
#' @param long.labels Detailed labels to give each track. If NULL the function attemps to gather from .bw file name: long.labels-*.bw
#' @param colors Colors (in R, G, B format) to give the tracks. If NULL colors will be auto-generated.
#' @param species Species information
#' @param region Brain region information
#' @param type Data type (ATAC, Multiome, etc.)
#' @param cluster Cluster label information
#' @param genome Genome information
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return A matrix of the infile
#' @export
generate.track.hub = function(hmac.encoded, 
                                track.bucket, access.key,
                                bigwigs, pseudo.names, long.labels, colors,
                                species, region, type, cluster, genome,
                                output.track.file, email){

    ## Define some helpful labels
    shortLabel = paste(region, type, sep=" ")
    longLabel  = paste(region, type, cluster, sep=" ")

    ## Open track hub file
    fileConnection = file(output.track.file, open="w+")

    ## Shub header
    writeLines(paste0("hub ", species, region, type, " Hub"), fileConnection)
    writeLines(paste0("shortLabel ", shortLabel, " Hub"), fileConnection)
    writeLines(paste0("longLabel ", longLabel, " Hub"), fileConnection)
    writeLines(paste0("useOneFile on"), fileConnection)
    writeLines(paste0("email ", email), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Genome info
    writeLines(paste0("genome ", genome), fileConnection)
    writeLines(paste0(""), fileConnection)

    # Multiwig header
    writeLines(paste0("track ", species, region, type, cluster), fileConnection)
    writeLines(paste0("container multiWig"), fileConnection)
    writeLines(paste0("shortLabel ", region, type), fileConnection)
    writeLines(paste0("longLabel ", region, type, cluster, " tracks"), fileConnection)
    writeLines(paste0("type bigWig"), fileConnection)
    writeLines(paste0("aggregate none"), fileConnection)
    writeLines(paste0("showSubtrackColorOnUi on"), fileConnection)
    writeLines(paste0("visibility full"), fileConnection)
    writeLines(paste0("autoScale on"), fileConnection)
    writeLines(paste0("alwaysZero on"), fileConnection)
    writeLines(paste0(""), fileConnection)

    ## Track writing
    for(bw.itr in 1:length(bigwigs)){
        writeLines(paste0("\ttrack ", pseudo.names[bw.itr]), fileConnection)
        writeLines(paste0("\tbigDataUrl https://s3-us-west-2.amazonaws.com/", track.bucket, "-tracks/", bigwigs[bw.itr], "?AWSAccessKeyId=", access.key, "&Expires=2147483647&Signature=", hmac.encoded[bw.itr]), fileConnection)
        writeLines(paste0("\tparent ", species, region, type, cluster), fileConnection)
        writeLines(paste0("\tshortLabel ", pseudo.names[bw.itr]), fileConnection)
        writeLines(paste0("\tlongLabel ", long.labels[bw.itr]), fileConnection)
        writeLines(paste0("\ttype bigWig"), fileConnection)
        writeLines(paste0("\tvisibility full"), fileConnection)
        writeLines(paste0("\tautoscale on"), fileConnection)
        writeLines(paste0("\tcolor ", paste(col2rgb(colors[bw.itr])[,1], collapse=",")), fileConnection)
        writeLines(paste0("\talwaysZero on"), fileConnection)
        writeLines(paste0("\tmaxHeightPixels 100:40:8"), fileConnection)
        writeLines(paste0("\tpriority ", bw.itr), fileConnection)
        writeLines(paste0(""), fileConnection)
    }
    close(fileConnection)
}
