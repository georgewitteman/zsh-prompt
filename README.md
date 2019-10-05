My ZSH Prompt
=============

Renders in 1-3ms. That's 333 – 1000 fps.

## How to write a fast ZSH prompt (or other zsh scripts)

By far the biggest way to speed up your prompt is to **avoid command substitution** whenever possible. Run `source test/param-vs-command-substitution.zsh` to see the difference. Based on that test parameter expansion if over 2000x faster than command substitution when running a simple command like `dirname`.

### Profiling and benchmarking

In order to start optimizing your prompt, you need to figure out what's actually slowing it down. There are a few different strategies that I used to figure out what was slowing down my prompt. The most useful one for me was the built in [`zprof`](http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html#The-zsh_002fzprof-Module) module. You can easily profile your own prompt by opening up a new terminal window, typing `zmodload zsh/zprof` and then holding down the enter key to render a bunch of prompts. Then, to view the output, type `zprof` or `zprof | head`. You should see a table of function calls sorted by self-execution time. Pay attention to the functions at the top of this table. Those are the functions that you'll need to optimize first.

There are some commands where it might be obvious that you're doing more complicated logic than necessary. For example, you might be searching for some strings in a file with a python script, where a simple call to grep would do just fine. It will be most helpful to benchmark how long different parts of your scripts/functions are taking to hone in on the slow areas. To do this I recommand loading the [`zsh/datetime`](http://zsh.sourceforge.net/Doc/Release/Zsh-Modules.html#The-zsh_002fdatetime-Module) module. This will give you access to a `$EPOCHREALTIME` variable which will give you the current time in microseconds or nanoseconds depending on your system. You can then set a variable to that time before a block of code and then compare the time after the block of code to that original (see `test/*` for examples).

From this, you'll start to be able to narrow down specific lines that are causing the issue. For example, one thing that I did not expect when I was starting this was how slow command substitution was, even for builtin commands. For example, try sourcing `test/pwd-comparison.zsh`. The first two tests use command substitution to set a variable to the current directory (`TESTVAR=$(pwd)`). It turns out that (on my machine at least) this is **135 times** slower than running just `pwd` without command substitution. Even though `$(pwd)` runs in just under 1ms, if its running in a loop that can easily add up. Other common commands like `dirname` take over 2.5ms to run on my machine. Again this might not sound like a lot, but you can see how if these commands are run over and over it could end up taking a lot of time.

In order to try and reduce this, I needed to try and find ways to not use command substitution. The zsh [prompt expansion](http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html) and [parameter expansion](http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion) docs were really helpful here. It turns out that there are a lot of things that zsh can do without ever calling another command. For example, running `VAR=$(dirname $(pwd))` takes about 3.5ms on my computer. Turns out there's a variable `$PWD` that I can use instead of `$(pwd)` which cuts that down to 2.6ms. But the real kicker is that if I get rid of command substitution altogether and use the `:h` parameter expansion flag I can get the same thing in **0.0012ms** by running `VAR=${PWD:h}`! To summarize, changing `VAR=$(dirname $(pwd))` (a pretty safe looking command) into `VAR=${PWD:h}` gave me a **2,770 times speedup**. Again, this few fractions of a millisecond might not sound like much, but when done tens or hundreds of time within a prompt script, it can be the difference between a hundreds of milliseconds prompt and a tens or even single digit milliseconds prompt.

### Why is command substitution so slow?
**TODO**

## What's next?
So, now that I have a zsh prompt that renders in under 4ms, I'd like to see if I can get my zsh startup time down. It's at about 100ms right now. Most of that is the [gitstatus](https://github.com/romkatv/gitstatus) plugin initialization. I'm guessing since the creator of gitstatus is also the creator of powerlevel10k it's already pretty optimized, but it's still worth a look.
