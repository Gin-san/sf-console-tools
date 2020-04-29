# Symfony Console Tools

### Setup

- Step 1 (setup console)

    $ ln -s /path/to/console.sh /usr/local/bin/console

- Step 2 (setup completion)

Add `source /path/to/console_completion.sh` on your `.bashrc` file

- Step 3 (generate completion cache)

Go to you symfony project with console package installed and run the following command

    $ __generate_console_completion_cache_file

To refresh your completion cache run again the same command.

Now completion will works with the console command


