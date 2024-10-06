# MP Report

## Team

- Name(s): Nikhil Singh Thakur
- AID(s): A20528528

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The simulator builds without error
- [X] The simulator runs on at least one configuration file without crashing
- [X] Verbose output (via the `-v` flag) is implemented
- [X] I used the provided starter code
- The simulator runs correctly (to the best of my knowledge) on the provided configuration file(s):
  - [X] conf/sim1.yaml
  - [X] conf/sim2.yaml
  - [X] conf/sim3.yaml
  - [X] conf/sim4.yaml
  - [X] conf/sim5.yaml\

## Summary and Reflection

**Replace this paragraph with a brief summary of notable implementation decisions you made and any additional notes that might help us evaluate your submission, including what you weren't able to get working correctly.**

For this project, I created a command-line tool in Dart to simulate a queueing system using settings from a YAML file. One of the main decisions I made was how to handle input from the user, like getting the file path for the config and whether or not they wanted extra details shown. I also had to make sure the program would exit properly if the config file wasn’t provided. I used Dart’s `yaml` package to read the simulation settings from the file, and the `Simulator` class (in `simulator.dart`) did most of the work running the simulation itself. 

I had some trouble with how Dart handles numbers, especially with mixing `int` and `double` types, which isn’t something I’m used to from working with Python. Python is more flexible with these things, so it took a bit of adjusting. I fixed most of these issues by making sure the data from the config file was passed in the right format.

For simulations 1 through 3, everything worked as expected. But with simulations 4 and 5, I couldn’t get the wait times to line up correctly.I have been working on the problem for more than 5 days straight but was not able to fix it. I tried multiple times, but the total wait time was just a bit off, which caused issues with the results in simulation 5. The number of events being processed was fine, but that small error in wait time threw things off. In simulation 5, the first three processes worked perfectly on their own, but when they were run together, the outcome didn’t match what was expected.

Since I’m new to Dart, I had to spend some time learning the syntax and looking up how things work, mainly using Dart’s cheat sheet (https://dart.dev/resources/dart-cheatsheet) and AI help to understand the flow of code and syntaxes meaning. I ran the code using `dart run bin/main.dart -c conf/sim1.yaml` and so on after every change to test the results but there were still some parts, especially in simulations 4 and 5, that I couldn’t fully get right.


**Replace this paragraph with notes on what you enjoyed/disliked, found challenging, or wish you had known before starting this MP.**

Before starting this Machine Problem (MP), I always thought Dart was mainly used for building apps that run on multiple platforms like iOS, Android, and macOS. But after working on this MP, I realized you can also use Dart for terminal-based projects and generate various outputs. I found that really interesting.
The most challenging part for me was understanding the processes, especially the Fourth one(Simulation 4), which involves a stochastic process. I struggled a bit with understanding the exponential distribution and how it applied to the problem.

Since I usually work with Python, I had to spend time learning Dart’s syntax. Dart’s stricter type system was something I had to adjust to which caused some type mismatch errors. This made the simulations a bit tricky, especially for simulations 4 and 5, where I still had some issues.

Overall, I enjoyed learning how Dart works, but I wish I had known more about the differences in type handling compared to Python before starting. It would have made the process smoother. I appreciated that Dart’s `for` loops and `if` statements are similar to Python, but the more structured syntax with semicolons and explicit types was something I had to get used to.