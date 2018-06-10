preview-motd ()
{
    author 'Nils Måsén'
    about ''
    param ''
    example ''
    group ''
    for f in /etc/update-motd.d/*
    do
        echo -e "\e[37m--- $f ---\e[39m"
        sudo bash $f
    done
}
