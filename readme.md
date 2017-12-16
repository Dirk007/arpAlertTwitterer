# arpAlertTwitter

Simple application to send a Twitter direct-message to one or recipients in case that `arpalert` called us
because of a suspicious network activity. The arpAlertTwitterer is free for any purpose and without warranty
of any kind. Use it at your own risk and responsibility. You can modify it, do whatever with it - have fun.
Keep in mind, that this application is just a quick hack that I made for my personal purpose. There is not even
any exception handling at the moment. Maybe one day, I just complete it 🤷.

However, if you like it, maybe you drop me a note to dirk[at]faustbande.de or by Twitter @faust_dirk.

## Prerequisites
This script is made for Python 3.

### arpalert
`arpalert` is a nice litte tool that listens for ARP packets and can call a script upon alert (this, for example).
Get it from here `https://www.arpalert.org/arpalert.html` or simply via `apt-get install arpalert` (or something
similar with your systems packet-manager). Note: I have nothing to do with `arpalert` except that I am using it.

### Tweepy
`Tweepy` is used for the Twitter part.
Get Tweepy via `pip3 install tweepy` or from here `https://github.com/tweepy/tweepy`