# odoo_docker_build

Sometimes you need additional Pyton libraries, so I forked the official Odoo Dockerfile and slightly adjusted it (thanks to Odoo team for such a a great product!)

1. Clone the repo
2. Copy `_env` into `.env` and edit it. A great way to create unique passwords is to launch the command in the terminal 
   ```shell 
   openssl rand -base64 14
   ```
3. You may comment the two last lines in the `build.sh` script to learn how to keep docker images locally
4. run `./build.sh` and enjoy
