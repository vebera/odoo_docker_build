# odoo_docker_build

Sometimes you need additional Python libraries, so I forked the official Odoo Dockerfile and slightly adjusted it (thanks to Odoo team for such a a great product!)

1. Clone the repo
2. Copy `_env` into `.env` and change the date of a nightly build.
3. run `./stack.sh -b` and enjoy

**New feature** - the scripts can now extract the SHA1 checksum automatically, you do not need to search for it anymore!
