# hubR
A tool to streamline the generate of UCSC browser hubs.

## Example: Building a track hub
```
library(hubR)

## Get bigwig file names
example.bigwigs = list.files("/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example", pattern='*.bw')

## Name of S3 track bucket
track.bucket = "NHP-BG-example"

## Generate signatures and write the UCSC track hub!
hubR(track.bucket = track.bucket, 
        access.key = "AKIAXEERKKJCONE3EJVO", secret.key = "TTGhaHb9gbWobMf+x6wcILN5f9CKfdXT1sVqrd1o",
        bigwigs = example.bigwigs, 
        species = "NHP", region="BG", type="Multiome", cluster="Subclass", genome="rhe10",
        output.track.file="/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example/trackDB.txt", 
        email="nelson.johansen@alleninstitute.org")

## Or if you just want signatures
hmac.signatures = create.signatures(track.bucket = track.bucket, secret.key = "TTGhaHb9gbWobMf+x6wcILN5f9CKfdXT1sVqrd1o", bigwigs = example.bigwigs)
```

## Example: Interacting with Amazon S3 via hubR
```
library(hubR)

## Track bucket must be exactly the same as above.
track.bucket = "NHP-BG-example"
hub.bucket   = "NHP-BG-hub"

## Add your credentials for API access
setup.aws(access.key = "AKIAXEERKKJCONE3EJVO", secret.key = "TTGhaHb9gbWobMf+x6wcILN5f9CKfdXT1sVqrd1o", region="us-west-2")

## Create 2 new buckets on S3 defaulted to "private"
add.buckets(track.bucket = track.bucket, hub.bucket = hub.bucket)

## Using aws-cli we will update the track bucket to completly private to secure data.
## aws-cli2 must be installed on the system to run this function, otherwise login and manually modify the bucket.
set.bucket.permissions(track.bucket = track.bucket, access.key = "AKIAXEERKKJCONE3EJVO", secret.key = "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")

## Now lets fill the track bucket with bigwig files!
fill.track.bucket(data.dir = "/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example", bigwigs = example.bigwigs, track.bucket = track.bucket)

## Finally lets add the track hub to the hub bucket!
fill.hub.bucket(data.dir = "/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example", hub.file = "trackDB.txt", hub.bucket = hub.bucket)
```


## Installing awscli2 for centos7
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install -i /usr/bin/aws-cli -b /usr/bin

aws --version
```

