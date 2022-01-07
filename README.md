# hubR
A tool to streamline the generate of UCSC browser hubs.

## Example
```
library(hubR)

## Get bigwig file names
example.bigwigs = list.files("/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example", pattern='*.bw')

## Name of S3 track bucket
track.dir = "NHP-BG-example"

## Generate signatures and write the UCSC track hub!
hubR(track.dir = track.dir, 
        access.key = "ABC", secret.key = "ABC,
        bigwigs = example.bigwigs, 
        species = "NHP", region="BG", type="Multiome", genome="rhe10",
        output.track.file="/allen/programs/celltypes/workgroups/hct/NelsonJ/hubR_example/trackDB.txt", 
        email="nelson.johansen@alleninstitute.org")

## Or if you just want signatures
hmac.signatures = create.signatures(track.dir = track.dir, secret.key = "ABC", bigwigs = example.bigwigs)
```

