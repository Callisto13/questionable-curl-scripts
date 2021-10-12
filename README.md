# Questionable Curl Scripts

These scripts are questionable indeed, and should not be relied upon to actually work.

They can be used to get release and issue data for `eksctl`, `pctl` and `profiles`.

### Usage:

```bash
export TOKEN=<your github PAT> # recommended to avoid API rate limiting but not required.

./releases.sh -u <github username> -y <year> -m <month as a 2-digit number>
# creates csv file containing release data for all 3 repos

./issues.sh -u <github username> -y <year> -m <month as a 2-digit number>
# creates 3 zip files release file containing data for all each repo
```

If something goes wrong with the `issues.sh` run, and you just want to re-run the parsing
without `curl`ing the world again, use the `-s` flag.

Run `releases.sh -h` or `issues.sh -h` for full usage info.
