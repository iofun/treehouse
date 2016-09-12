# -*- coding: utf-8 -*-
'''
    Say stochastic things.
'''

# This file is part of simon.

__author__ = 'Jean Chassoul'


import random


# change to enum's magic.
_bonaparte_quotes = {
    0: "Oh oh ah uuh uh ah eh ohh uh...",

    1:"A little braindead, around the edges!"
}

_john_carmack_quotes = {
    0:"In the information age, the barriers just aren't there. " \
        "The barriers are self imposed. If you want to set off and " \
        "go develop some grand new thing, you don't need millions of " \
        "dollars of capitalization. You need enough pizza and Diet " \
        "Coke to stick in your refrigerator, a cheap PC to work " \
        "on, and the dedication to go through with it. We slept on " \
        "floors. We waded across rivers.",

    1:"Honestly, I spend very little time thinking about past events, " \
        "and I certainly don't have them ranked in any way. I look " \
        "back and think that I have done a lot of good work over the " \
        "years, but I am much more excited about what the future holds.",
        
    2:"Because of the nature of Moore's law, anything that an " \
        "extremely clever graphics programmer can do at one point " \
        "can be replicated by a merely competent programmer "\
        "some number of years later.",

    3:"The situation is so much better for programmers today - " \
        "a cheap used PC, a linux CD, and an internet account, " \
        "and you have all the tools necessary to work your way to "\
        "any level of programming skill you want to shoot for.",

    4:"It's done, when it's done.",

    5:"The idea that I can be presented with a problem, set out to " \
        "logically solve it with the tools at hand, and wind up with a " \
        "program that could not be legally used because someone else " \
        "followed the same logical steps some years ago and filed for " \
        "a patent on it is horrifying",

    6:"Programming in the abstract sense is what I really enjoy. " \
        "I enjoy lots of different areas of it... I'm taking a great " \
        "deal of enjoyment writing device drivers for Linux. I could " \
        "also be having a good time writing a database manager or " \
        "something because there are always interesting problems.",

    7:"Personally, I've always been of the sleek and minimalist "\
        "design school: make sure the core play is consistent and "\
        "strong, then let that idea play out against different "\
        "environments and challenges, this tends toward focusing "\
        "on bio-mechanical twitch responses, audio-visual awe, and "\
        "leaning more toward general strategy and tactics development "\
        "over specific puzzle solving.",

    8:"Sharing the code just seems like The Right Thing to Do, it " \
        "costs us rather little, but it benefits a lot of people in " \
        "sometimes very significant ways. There are many university " \
        "research projects, proof of concept publisher demos, and " \
        "new platform test beds that have leveraged the code. Free " \
        "software that people value adds wealth to the world.",

    9:"Focus is a matter of deciding what things you're not going " \
        "to do.",
}

# get json medium fun-technology

class PeopleQuotes(object):
    
    def __init__(self):
        self.quotes = _john_carmack_quotes
    
    def get(self):
        x = random.randrange(0, len(self.quotes))
        return self.quotes[x]