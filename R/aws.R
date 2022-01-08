#' Setup aws.s3 
#'
#' This function takes in the users AWS credentials and primes aws.s3.
#'
#' @param access.key Amazon S3 access key ID
#' @param secret.key Amazon S3 access key ID
#' @param region Amazon S3 region: default 'us-west-2'
#'
#' @export
setup.aws = function(access.key='AKIAXEERKKJCONE3EJVO', secret.key='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', region="us-west-2"){
    Sys.setenv("AWS_ACCESS_KEY_ID" = access.key,
               "AWS_SECRET_ACCESS_KEY" = secret.key,
               "AWS_DEFAULT_REGION" = region)
}

#' Create buckets 
#'
#' This function creates a track and hub bucket on Amazon S3
#'
#' @param track.bucket Name to be given for track bucket on Amazon S3. (Must be all lower-case)
#' @param hub.bucket Name to be given for hub bucket on Amazon S3. (Must be all lower-case)
#'
#' @export
add.buckets = function(track.bucket, hub.bucket){
    ## Add track bucket (private)
    put_bucket(bucket = tolower(track.bucket),
                region = Sys.getenv("AWS_DEFAULT_REGION"),
                acl = "private")

    ## Add hub bucket (public)
    put_bucket(bucket = tolower(hub.bucket),
                region = Sys.getenv("AWS_DEFAULT_REGION"),
                acl = "private")
}

#' Update bucket permission
#'
#' This function is intended to update the track bucket to be completly private
#'
#' @param track.bucket Name of the track bucket on Amazon S3. 
#' @param access.key Amazon S3 access key ID
#' @param secret.key Amazon S3 access key ID
#'
#' @export
set.bucket.permissions = function(track.bucket, access.key="AKIAXEERKKJCONE3EJVO", secret.key="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"){
    ## Configure AWS CLI
    system(paste0("aws configure set aws_access_key_id ", access.key))
    system(paste0("aws configure set aws_secret_access_key ", secret.key))

    ## Update bucket to be completly private
    system(paste0("aws s3api put-public-access-block --bucket ", tolower(track.bucket), ' --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'))
}

#' Populate track bucket with bigwigs
#'
#' This function takes as input the data directory and file names for the bigwig files and uploads them to the track bucket.
#'
#' @param data.dir Directory where the bigwig files exist
#' @param bigwigs Names of the bigwig files
#' @param track.bucket Name of the track bucket on Amazon S3. 
#'
#' @export
fill.track.bucket = function(data.dir, bigwigs, track.bucket){
    for(bw in bigwigs){
        put_object(file=file.path(data.dir, bw), object=bw, bucket=tolower(track.bucket), multipart=TRUE)
    }
}

#' Upload hub file to hub bucket
#'
#' This function takes as input the data directory and file name for the hub file and uploads it to the hub bucket.
#'
#' @param data.dir Directory where the bigwig files 
#' @param hub.file Hub file produced by hubR
#' @param hub.bucket Name of the hub bucket on Amazon S3. 
#'
#' @export
fill.hub.bucket = function(data.dir, hub.file, hub.bucket){
    put_object(file=file.path(data.dir, hub.file), object=hub.file, bucket=tolower(hub.bucket), acl="public-read")
}

