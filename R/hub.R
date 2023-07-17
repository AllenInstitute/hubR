#' Builds a track hub for the UCSC genome browser
#'
#' This builds the track hub and handles all uploading to AWS S3 buckets as named in track.bucket and hub.bucket.
#' Any changes to the bigwig file names or 'track.bucket' will require the regeneration of HMAC signatures and the hub file (rerun hubR).
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param hub.bucket Amazon S3 bucket name that stores the track hub .txt file
#' @param data.dir Location of the bigwig files and where the trackDB.txt will be saved locally
#' @param species Species information
#' @param region Brain region information
#' @param type Data type (ATAC, Multiome, etc.)
#' @param taxonomy Annotation information
#' @param genome Genome information, must be a valid UCSC genome browser genome.
#' @param bigwigs Either a directory or vector of file names for bigwigs. If a vector, then the order of the vector will define the order of the tracks.
#' @param track.names  Short labels to give each track. If NULL the function attemps to gather from .bw file name: track.names-*.bw
#' @param track.labels Detailed labels to give each track. If NULL the function attemps to gather from .bw file name: track.labels-*.bw
#' @param colors Colors (in R, G, B format) to give the tracks. If NULL colors will be auto-generated.
#' @param groupby A vector of grouping variables for the bigwigs when building composite or sea-ad tracks.
#' @param hub.type Format of the track hub: multiwig or composite
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return Hub URL
#'
#' @export
hubR = function(track.bucket, hub.bucket, data.dir,
                species, region, type, taxonomy, genome,
                bigwigs=NULL, track.names=NULL, track.labels=NULL, colors=NULL, groupby=NULL,
                hub.type = "multiwig", output.track.file="trackDB.txt", email="nelson.johansen@alleninstitute.org"){

    ## AWS argument checking
    track.bucket = .argcheck.bucket.names(track.bucket)
    hub.bucket   = .argcheck.bucket.names(hub.bucket)

    ## This is the bucket name before the object path
    base.bucket  = strsplit(track.bucket, "/")[[1]][1]

    ## Bigwig files
    bigwigs = .argcheck.bigwigs(data.dir, bigwigs)

    ## Argument checking and generation if not provided
    bw.df = data.frame(bigwig      = bigwigs,
                       track.name  = .argcheck.track.names(track.names, bigwigs),
                       track.label = .argcheck.track.labels(track.labels, bigwigs),
                       colors      = .argcheck.colors(colors, bigwigs),
                       groupby     = .argcheck.groupby(groupby, bigwigs))

    ## Data.frame to hold data level information
    anno.df = data.frame(species  = species, 
                         region   = region, 
                         type     = type, 
                         taxonomy = taxonomy, 
                         genome   = genome)
    
    ## Compute hmac signatures using sha1
    bw.df$hmac.encoded = create.signatures(track.bucket, bw.df)

    ## Write out the hub file
    print("-- Step 1: Creating track hub '.txt' file")
    generate.track.hub(track.bucket,
                       hub.type,
                       bw.df,
                       anno.df,
                       file.path(data.dir, output.track.file), email)

    ## Create buckets on AWS S3
    print("-- Step 2: Creating buckets on AWS S3")
    add.bucket(bucket = base.bucket)

    ## Using aws-cli we will update the track bucket to completly private to secure data.
    # tryCatch(set.bucket.permissions(track.bucket = track.bucket),
    #     error=function(cond) {
    #         message("FAILED TO UPDATE PERMISSIONS")
    #         message("LOG INTO AWS S3 AND SET TRACK BUCKET TO PRIVATE")
    #     }
    # )

    ## Now lets fill the track bucket with bigwig files!
    print("-- Step 2: Filling buckets on AWS S3")
    fill.hub.bucket(data.dir = data.dir, hub.file = output.track.file, hub.bucket = hub.bucket)
    fill.track.bucket(data.dir = data.dir, bigwigs = bigwigs, track.bucket = track.bucket)
    print("-- Done! ")

    ## Report the URL
    bucket = strsplit(hub.bucket, "/")[[1]][1] ## Get the bucket
    object.prefix = paste(strsplit(hub.bucket, "/")[[1]][-1], collapse="/") ## Get the object prefix path
    URL = paste0("https://", bucket, ".s3.", Sys.getenv("AWS_DEFAULT_REGION"), ".amazonaws.com/", object.prefix, "/", output.track.file)
    print(paste0("Hub link: ", URL))
    return(URL)
}

#' Computes HMAC signatures
#'
#' This function takes in a vector of bigwig file names and Amazon S3 credentials to generate hmac signatures to access .bw files.
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param bigwigs Bigwig file names which exactly match those in 'track.bucket'
#'
#' @keywords internal
create.signatures = function(track.bucket, bw.df){
    ## Following original conventions with respect to sha1
    hmac.encoded = sapply(bw.df$bigwig, function(x) URLencode(base64Encode(hmac(Sys.getenv("AWS_SECRET_ACCESS_KEY"), paste0("GET\n\n\n2147483647\n/", track.bucket, "/", x), "sha1", raw=TRUE)), reserved=TRUE))
    return(hmac.encoded)
}

#' Build the track hub
#'
#' This function ..
#'
#' @param track.bucket Amazon S3 bucket name that stores the .bw files
#' @param hub.type Hub format: multiwig or composite
#' @param bw.df Data.frame holding all bigwig and track information supplied by user.
#' @param anno.df Data.frame holding all data level information supplied by user.
#' @param output.track.file Output track hub filename. Default: trackDB.txt
#' @param email Correspondence email
#'
#' @return A matrix of the infile
#' @keywords internal
generate.track.hub = function(track.bucket,
                                hub.type,
                                bw.df,
                                anno.df,
                                output.track.file, email){
    if(hub.type == "multiwig"){
        generate.multiwig.track.hub(track.bucket,
                                    bw.df,
                                    anno.df,
                                    output.track.file, email)
    }else if(hub.type == "composite"){
        # generate.composite.track.hub(track.bucket,
        #                             bw.df,
        #                             anno.df,
        #                             output.track.file, email)
        stop("composite hub not ready, use multiwig or sea-da.")
    }else if(hub.type == "sea-ad"){
        generate.sea.ad.track.hub(track.bucket,
                                  bw.df,
                                  anno.df,
                                  output.track.file, email)
    }else{
        stop("Unrecognized hub type should be either: multiwig or sea-ad")
    }
}
