#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
arpAlertTwitterer

Simple application to send a Twitter direct-message to one or recipients in case that `arpalert` called us
because of a suspicious network activity. The arpAlertTwitterer is free for any purpose and without warranty
of any kind. Use it at your own risk and responsibility. You can modify it, do whatever with it - have fun.
Keep in mind, that this application is just a quick hack that I made for my personal purpose. There is not even
any exception handling at the moment. Maybe one day, I just complete it 🤷.

However, if you like it, maybe you drop me a note to dirk@ƒaustbande.de or by Twitter @faust_dirk.

`arpalert` is a nice litte tool that listens for ARP packets and can call a script upon alert (this, for example).
Get it from here `https://www.arpalert.org/arpalert.html` or simply via `apt-get install arpalert` (or something
similar with your systems packet-manager). Note: I have nothing to do with `arpalert` except that I am using it.
"""

import ast
import configparser
import os
import sys
import tweepy

# This is good for macOS and Linux. Windows probably needs some love here.
_configFile = '/etc/arpAlertTwitterer.conf'


def main(arp_alert_arguments):
    """
    Main entry point.
    :param arp_alert_arguments: all arguments passed from arpalert script call to this process.
           For example: "aa:bb:cc:11:22:33 192.168.123.123  eth0 3 Some Vendor Name"
    :return: nothing
    """
    config = read_configuration()
    vendor_name = ' '.join(arp_alert_arguments[4:])

    message = ("👀  New device seen on `{device}`!{lf}{lf}"
               "MAC: {mac} ({vendor}){lf}"
               "IP: {ip}{lf}"
               "Maybe you take a look...🤷{lf}{lf}"
               "Cheers, your ARP bot".format(lf=os.linesep,
                                             device=arp_alert_arguments[2],
                                             state=arp_alert_arguments[3],
                                             vendor=vendor_name,
                                             mac=arp_alert_arguments[0],
                                             ip=arp_alert_arguments[1]))

    for recipient in config['recipients']:
        print("Sending to {name}".format(name=recipient))
        twitter = get_twitter_api(config)
        twitter.send_direct_message(user='@' + recipient, text=message)


def get_twitter_api(config):
    """
    Create an authenticated Tweepy Twitter API object.
    :param config: Config that holds the tokens and keys.
    :return: Tweepy-API object
    """
    auth = tweepy.OAuthHandler(config['consumer_key'], config['consumer_secret'])
    auth.set_access_token(config['access_token'], config['access_token_secret'])
    return tweepy.API(auth)


def read_configuration():
    """
    Read the configuration from _configFile(="/etc/arpTwitterer.conf" by default)
    :return: Configuration-dict with Twitter tokens and keys as well as recipient-array to send the alerts to.
    """
    if not os.path.isfile(_configFile):
        print(("Config file not found: {configFile}.{lf}"
               "You can copy the sample-configuration example.conf and fill in the tokens with yours from twitter if "
               "you are not sure what to do.{lf}{lf}"
               "If you do not have them, create an app here: https://apps.twitter.com/ "
               "and simply copy them from there when done.".format(configFile=_configFile,
                                                                   lf=os.linesep)))
        sys.exit(1)

    # We only have one section inside the config file
    section = 'twitter'

    configParser = configparser.ConfigParser()
    configParser.read("/etc/arpAlertTwitterer.conf")

    return {'access_token': ast.literal_eval(configParser[section]['access_token']),
            'access_token_secret': ast.literal_eval(configParser[section]['access_token_secret']),
            'consumer_key': ast.literal_eval(configParser[section]['consumer_key']),
            'consumer_secret': ast.literal_eval(configParser[section]['consumer_secret']),
            'recipients': ast.literal_eval(configParser[section]['recipients'])}


if __name__ == "__main__":
    main(sys.argv[1:])
