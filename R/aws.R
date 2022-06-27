#' Setup aws.s3 
#'
#' This function takes in the users AWS credentials and primes aws.s3.
#'
#' @param access.key Amazon S3 access key ID
#' @param secret.key Amazon S3 access key ID
#' @param region Amazon S3 region: default 'us-west-2'
#'
#' @export
setup.aws = function(access.key, secret.key, region="us-west-2"){
    Sys.setenv("AWS_ACCESS_KEY_ID" = access.key,
               "AWS_SECRET_ACCESS_KEY" = secret.key,
               "AWS_DEFAULT_REGION" = region)
}

#' Setup awscli2
#'
#' This function adds an awscli2 install to the users PATH
#'
#' @param awscli.path directory where awscli2 was installed
#'
#' @export
setup.awscli = function(awscli.path = "/allen/programs/celltypes/workgroups/hct/NelsonJ/Home/v2/2.4.9/bin"){
    Sys.setenv(PATH = paste(Sys.getenv("PATH"), awscli.path, sep = ":"))
}

#' Create buckets 
#'
#' This function creates a track and hub bucket on Amazon S3
#'
#' @param track.bucket Name to be given for track bucket on Amazon S3. (Must be all lower-case)
#' @param hub.bucket Name to be given for hub bucket on Amazon S3. (Must be all lower-case)
#'
#' @keywords internal
add.buckets = function(track.bucket, hub.bucket){
    ## Add track bucket (private)
    if(!bucket_exists(track.bucket)){
        put_bucket(bucket = track.bucket,
                    region = Sys.getenv("AWS_DEFAULT_REGION"),
                    acl = "private")
    }else{
        print("Track bucket already exists")
    }

    ## Add hub bucket (private)
    if(!bucket_exists(hub.bucket)){
        put_bucket(bucket = hub.bucket,
                    region = Sys.getenv("AWS_DEFAULT_REGION"),
                    acl = "private")
    }else{
        print("Hub bucket already exists")
    }
}

#' Update bucket permission
#'
#' This function is intended to update the track bucket to be completly private
#'
#' @param track.bucket Name of the track bucket on Amazon S3. 
#'
#' @keywords internal
set.bucket.permissions = function(track.bucket){
    ## Configure AWS CLI
    system(paste0("aws configure set aws_access_key_id ", "\"", Sys.getenv("AWS_ACCESS_KEY_ID"), "\""))
    system(paste0("aws configure set aws_secret_access_key ", "\"", Sys.getenv("AWS_SECRET_ACCESS_KEY_ID"), "\""))
    ## Update bucket to be completly private
    system(paste0("aws s3api put-public-access-block --bucket ", track.bucket, ' --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'))
}

#' Populate track bucket with bigwigs
#'
#' This function takes as input the data directory and file names for the bigwig files and uploads them to the track bucket.
#'
#' @param data.dir Directory where the bigwig files exist
#' @param bigwigs Names of the bigwig files
#' @param track.bucket Name of the track bucket on Amazon S3. 
#'
#' @keywords internal
fill.track.bucket = function(data.dir, bigwigs, track.bucket){

    ## Get bucket content to not reupload 
    bucket.df = get_bucket_df(track.bucket)

    ## Upload bigwigs
    for(bw in bigwigs){
        if(bw %in% bucket.df$Key == TRUE){
            print(paste0("Skipping: ", bw))
        }else{
            print(paste0("Uploading: ", bw))
            put_object(file=file.path(data.dir, bw), object=bw, bucket=track.bucket, multipart=TRUE)
        }
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
#' @keywords internal
fill.hub.bucket = function(data.dir, hub.file, hub.bucket){
    put_object(file=file.path(data.dir, hub.file), object=hub.file, bucket=hub.bucket, acl="public-read", multipart=TRUE)
}

