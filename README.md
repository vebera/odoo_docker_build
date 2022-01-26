# odoo_docker_build

Sometimes you need additional Pyton libraries, so I forked the official Odoo Dockerfile and slightly adjusted it (thanks to Odoo team for such a a great product!)

1. Clone the repo
2. Copy `_env` into `.env` and edit it.
3. You may comment the two last lines in the `build.sh` script to learn how to keep docker images locally
4. run `./build.sh` and enjoy

**New feature** - the scripts can now extract the SHA1 checksum automatically, you do not need to search for it anymore!
