Add to ~/.bashrc

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
