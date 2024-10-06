# Queueing Simulator

## 1. Overview

This project implements a simple user profile page using the Dart programming language and the Flutter framework. The profile page displays personal information such as the user's name, email, phone number, address, and profile picture. This mobile-based application serves as a practical exercise to work with Flutter’s UI elements, state management, and file handling.

## 2. Queueing systems


A queueing system manages requests for a resource and facilitates servicing those requests as the resource becomes available.

For instance, a grocery checkout lane functions as a queueing system. Here, "requests" are customers looking to check out, and the "resource" is the checkout clerk/machine. The requests are tracked in a physical line, where customers are serviced in order of arrival (FIFO). The service time for each request is proportional to the number of items in a customer's cart.

Similarly, an event-driven software application, whether graphical or not, operates as a queueing system. Here, requests may include user input, network traffic, or I/O completion, collectively known as "events". The resource is the CPU, which runs the appropriate code to handle each event. A queue data structure is often used to track outstanding events, and service times depend on the complexity of the handler routines.

Of particular interest when analyzing queueing systems are statistics related to how long requests are forced to *wait* before being granted access to their requested resource. For instance, if an event arrives into an empty queue, its *wait time* for service is 0. On the other hand, if an event arrives into a queue with existing events, its wait time is the sum of those events' service times.

E.g., consider the following table of event arrival and service times:

| Event # | Arrival time | Service time |
|---------|--------------|--------------|
| 1       | 0            | 4            |
| 2       | 3            | 7            |
| 3       | 5            | 3            |
| 4       | 10           | 6            |

Event 1 arrives at time 0 to an empty queue and is serviced without any wait time. Event 2 arrives at time 3, but since event 1 is still being serviced, has to wait 1 time unit to be serviced. Event 3 arrives at time 5, but since event 2 is still being serviced, has to wait 6 time units to be serviced. Event 4 arrives at time 10, but has to wait 4 time units for events 2 and 3 to finish being serviced before being serviced itself. The average wait time for this queue is (0 + 1 + 6 + 4) / 4 = 2.75 time units.

The following [Gantt chart](https://en.wikipedia.org/wiki/Gantt_chart) illustrates the above example, where each row represents an event's timeline -- red bars represent times that events are waiting, and blue bars represent times that events are being serviced:

![Gantt chart](images/ganttchart.png)

## 3. Simulator overview

Our simulator will model a queueing system that services events generated by various *processes*. These processes include singleton, periodic, and stochastic types.

1. **Singleton process**: Generates a single event with a fixed duration and arrival time.
2. **Periodic process**: Generates multiple events with fixed durations, separated by fixed interarrival times.
3. **Stochastic process**: Generates multiple events with durations and interarrival times based on [exponential probability distributions](https://en.wikipedia.org/wiki/Exponential_distribution).

Processes for a given simulation run are specified by way of a YAML configuration file. Details of how processes are configured are given in the next section, "Process configuration."

After reading a process configuration file, the simulator will run the simulation and print out a report containing the following information:

1. On a per-process basis (identified by name), the number of events generated, the total wait time across events, and the average wait time across events.
2. A summary indicating the total number of events serviced, the total wait time, and the average wait time (across all processes).

E.g., for the example given in the "Queueing systems" section, the simulator would output the following (preceded by an optional simulation trace):

```markdown
# Simulation trace

t=0: Process 1, duration 4 started (arrived @ 0, no wait)
t=4: Process 2, duration 7 started (arrived @ 3, waited 1)
t=11: Process 3, duration 3 started (arrived @ 5, waited 6)
t=14: Process 4, duration 6 started (arrived @ 10, waited 4)

--------------------------------------------------------------

# Per-process statistics

Process 1:
  Events generated:  1
  Total wait time:   0
  Average wait time: 0.0

Process 2:
  Events generated:  1
  Total wait time:   1
  Average wait time: 1.0

Process 3:
  Events generated:  1
  Total wait time:   6
  Average wait time: 6.0

Process 4:
  Events generated:  1
  Total wait time:   4
  Average wait time: 4.0

--------------------------------------------------------------

# Summary statistics

Total num events:  4
Total wait time:   11.0
Average wait time: 2.75
```

## 4. Process configuration

Processes used in a given simulation run are specified by a YAML configuration file. Below we specify the configuration options for each process type:

- A **singleton** process generates a single event with a fixed, finite duration (aka service time) and a pre-determined arrival time. `duration` and `arrival` are required entries. Here's a sample singleton process entry:

  ```yaml
  Computation:
    type: singleton
    duration: 1000
    arrival: 25
  ```

  This describes a process named "Computation", which generates a single event of duration 1000, which arrives at time 25.

- A **periodic** process generates multiple events with fixed durations, and fixed interarrival times. `duration`, `interarrival-time`, `first-arrival`, and `num-repetitions` are required entries. Here's a sample periodic process entry:

  ```yaml
  Repeating task:
    type: periodic
    duration: 100
    interarrival-time: 500
    first-arrival: 35
    num-repetitions: 50
  ```
  
  This describes a process named "Repeating task" which generates events of fixed duration 100. The first event generated by this process arrives at time 35, and this process will generate 50 events in total. Events arrive every 500 time units after the first arrival. Note that if the interarrival time is shorter than the duration, events will pile up!

- A **stochastic** process generates multiple events whose durations and interarrival times are based on exponential probability distributions. Here's a sample stochastic process entry:

  ```yaml
  I/O request:
    type: stochastic
    mean-duration: 50
    mean-interarrival-time: 150
    first-arrival: 100
    end: 3000
  ```

  This describes a process named "I/O request", which generates events whose durations follow an exponential probability distribution with a mean of 50. The first event generated by this process arrives at time 100, and the process will stop generating events after time 3000. The time between the arrival of events follows an exponential probability distribution with a mean of 150.

### 4.1. Sample configuration file & output  

The following is a sample configuration file that contains one of each process type:

```yaml
Computation:
  type: singleton
  duration: 50
  arrival: 10

Timer interrupt:
  type: periodic
  duration: 10
  interarrival-time: 25
  first-arrival: 0
  num-repetitions: 3

I/O request:
  type: stochastic
  mean-duration: 10
  mean-interarrival-time: 25
  first-arrival: 5
  end: 150
```

And for reference, here is the output of a simulation run based on the above configuration (note that events generated by the stochastic process have random durations and interarrival times based on the exponential distribution):

```markdown
# Simulation trace

t=0: Timer interrupt, duration 10 started (arrived @ 0, no wait)
t=10: I/O request, duration 18 started (arrived @ 5, waited 5)
t=28: Computation, duration 50 started (arrived @ 10, waited 18)
t=78: Timer interrupt, duration 10 started (arrived @ 25, waited 53)
t=88: I/O request, duration 22 started (arrived @ 49, waited 39)
t=110: Timer interrupt, duration 10 started (arrived @ 50, waited 60)
t=120: I/O request, duration 6 started (arrived @ 104, waited 16)
t=126: I/O request, duration 13 started (arrived @ 118, waited 8)

--------------------------------------------------------------

# Per-process statistics

Computation:
  Events generated:  1
  Total wait time:   18
  Average wait time: 18.0

Timer interrupt:
  Events generated:  3
  Total wait time:   113
  Average wait time: 37.67

I/O request:
  Events generated:  4
  Total wait time:   68
  Average wait time: 17.0

--------------------------------------------------------------

# Summary statistics

Total num events:  8
Total wait time:   199.0
Average wait time: 24.875
```

## 5. Implementation details and hints

We must implement all parts of the simulator in pure Dart code. We **strongly suggest** the following breakdown, though you are free to structure your code as you see fit, so long as you keep it modular and logical:

- A `main` function that parses command line arguments, reads the configuration file, and initializes and starts the simulation.
- A `Simulation` class that is initialized with configuration data, and has methods for running the simulation and printing the report.
- A `Process` class that represents a single process, with subclasses for each of the three process types. A `Process` object should be able to generate a list of `Event` objects based on its configuration.
- An `Event` class that represents a single event.

We provide stubs for some of these classes in the `lib` directory. You are free to use them as a starting point or to delete/replace them entirely.

The heart of the simulator is the `run` method (or equivalent) in the `Simulation` class. This method should iterate over a combined queue of all events generated by configured processes, sorted by order of arrival. The simulator should keep track of the current time, and update `Event` objects with their actual start/wait times as they are processed. As events are processed, they should be removed from the event queue and saved elsewhere for reporting purposes.

### 5.1. Parsing command line arguments and YAML files

To deal with command line arguments and YAML files, you should use the `args` and `yaml` packages, respectively. We have already added these dependencies to the `pubspec.yaml` file for you. Note that you should **not** add any additional dependencies to your `pubspec.yaml` file!

We have also included code in the `main.dart` file that handles command line arguments gracefully, and loads the specified YAML file. You can use this code as a starting point for your implementation.

### 5.2. Exponential distribution samples

To aid in the generation of random samples from the exponential distribution, we provide the class `ExpDistribution`, found in `lib/util/stats.dart`. To use it, create an instance of `ExpDistribution` with a mean value, and call the `sample` method to generate a random sample from the distribution. E.g., to generate a random sample from an exponential distribution with a mean of 100:

```dart
var exp = ExpDistribution(mean: 100);
var sample = exp.next();
```

Repeated calls to `next` will generate different random samples from the distribution with the mean specified in the constructor.

### 5.3. Running/Testing the simulator

To run the simulator, use a command like the following in your terminal:

```bash
dart run bin/main.dart -c <path/to/config.yaml>
```

Where `<path/to/config.yaml>` is the path to the YAML configuration file that specifies the processes to simulate. We include five configuration files in the `conf` directory (named `sim[1-5].yaml`) for you to test your implementation, so a valid command might look like:

```bash
dart run bin/main.dart -c conf/sim1.yaml
```

If we include the `-v` flag in the invocation (e.g., `dart run bin/main.dart -c conf/sim1.yaml -v`), the `verbose` Boolean variable in the `main` function will be set to `true`, and you can pass this flag to the `Simulation` constructor to enable verbose output, if you implement this feature.

We can also debug our code in VSCode by going to the "Run and Debug" tab, selecting one of the configurations from the dropdown (with names like "Simulation 1", "Simulation 2", etc.), and then clicking the green play button (after setting any desired breakpoints). We set up launch configurations for you so that each dropdown option invokes the simulator with the correspondly numbered configuration file.


