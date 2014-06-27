#Setting up a git deploy environment on Bluehost

version 0.0.1

###Update Git on Bluehost
Because Bluehost shared hosts are stuck on version 1.7


Enable SSH for your bluehost account, then use SSH to access your Bluehost account. Open .bashrc and add a new PATH variable pointing to git-master directory.

```
$ cd
$ nano .bashrc

# Add updated Git binaries location
export PATH="$HOME/.local/src/git-master:$PATH"
``` 

​Now change directory to (or create) ~/.local. Create and CD to a new directory called src.

```
$ mkdir .local && cd .local
$ mkdir src && cd src
```

Download the Git source code into src, unzip, remove .zip, install. 

```
$ wget --no-check-certificate https://github.com/git/git/archive/master.zip
$ unzip master
$ rm master.zip

$ cd git-master
$ make
$ make install
```

​Once the source has compiled and installed, log out and in, test the installation by entering the following command, and it should report any version higher than 1.7.11.3

```
$ git --version
```

##Setting up Server files

Ssh into the server set up a bare repository at ~/repositories. Don't make an individual repo, the script will do that. Also create ~/public_html/production and ~/public_html/staging while you're at it.

```
$ mkdir ~/repositories && cd ~/repositories
$ mkdir ~/public_html/production && ~/public_html/staging
```

Update "post-receive.sh" `homedir` variable with the server-specific path and copy it to the repository directory.

Open .bashrc and paste the `newgit()` function updated with server-specific path in `homedir` variable.

```
nano ~/.bashrc
```
```
#.bashrc function to create and prep for push and deploy
newgit()  
{
   if [[ (-z $1) || (-z $2) ]]; then
       echo "usage: $FUNCNAME environment domain.tld"
   else
       homedir="/home/islaneb5"
       webdir="$homedir/public_html/$1/$2"
       gitdir="$homedir/repositories/$1.$2.git"
       mkdir $gitdir
       pushd $gitdir
       git --bare init
       git --bare update-server-info
       touch $gitdir/hooks/post-receive
       echo "source $homedir/repositories/post-receive.sh $1.$2 $2 $1" >>$gitdir/hooks/post-receive
       chmod a+x $gitdir/hooks/post-receive
       touch git-daemon-export-ok
       popd
   fi
}

```

You now have a new function newgit to be run in terminal. When run like so `newgit environment domain.tld` it will create a new bare repository environment.domain.tld.git with a post-receive hook that clones all relevant files to `~/public_html/environment/domain.tld` after a push (while also respecting submodules).

##Set up Local Machine

Add server remotes to local git repositories. `ssh://user@domain.tld/home/username/repositories/environment.domain.tld.git`. I recommend naming one Production and another Staging after different standard environments (supposing the local machine is functions as a Development environment).

Push the appropriate branch to the bare repo `git push remote master`. This should be a successful push. If you get fatal errors in the log, it's probably a mistyped directory in any of these config files we set up.

Add dummy files `production_env` and `staging_env` to appropriate directories in public_html directory for `wp-config.php` setup.