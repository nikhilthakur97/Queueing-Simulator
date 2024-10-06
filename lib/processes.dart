// provided by professor a utility that provides random distributions
import '/util/stats.dart';

//it is class defines an event which has a name, arrival time, duration, and a start time.
class Event implements Comparable<Event> {
  final String processName;  // Name of the process
  final double arrivalTime;  
  final double duration;     
  late double startTime;     

  // Constructor to create an event
  Event(this.processName, this.arrivalTime, this.duration);

  // This function allows us to compare two events based on their arrival time.
  @override
  int compareTo(Event other) => arrivalTime.compareTo(other.arrivalTime);
}

// A template for different types of processes).
abstract class Process {
  final String name;   
  final Map config;   

  Process(this.name, this.config);  // Constructor that assigns name and config

  // generate the events required
  List<Event> generateEvents();
}

// A specific type of process that generates just one event (singleton).
class SingletonProcess extends Process {
  SingletonProcess(String name, Map config) : super(name, config);

  //it generates a single event based on the arrival time and duration from the config.
  @override
  List<Event> generateEvents() {
    return [
      Event(
          name,
          (config['arrival'] as num).toDouble(), 
          (config['duration'] as num).toDouble() 
          )
    ];
  }
}

// a process that creates events repeatedly at fixed intervals.
class PeriodicProcess extends Process {
  PeriodicProcess(String name, Map config) : super(name, config);

  //generates multiple events at regular time intervals (specified in config).
  @override
  List<Event> generateEvents() {
    List<Event> events = [];
    double arrivalTime = (config['first-arrival'] as num).toDouble();  // When the first event should arrive

    // Loop through, creating multiple events based on the number of repetitions.
    for (int i = 0; i < config['num-repetitions']; i++) {
      events.add(
          Event(name, arrivalTime, (config['duration'] as num).toDouble()));  // Add each event
      arrivalTime += (config['interarrival-time'] as num).toDouble();  // Add the interarrival time for the next event
    }
    return events;
  }
}

// A process that generates events at random intervals (stochastic).
class StochasticProcess extends Process {
  late ExpDistribution durationDist;        // Random distribution for event duration
  late ExpDistribution interarrivalDist;    // Random distribution for the time between events

  // Constructor for StochasticProcess, sets up the random distributions for event duration and interarrival time.
  StochasticProcess(String name, Map config) : super(name, config) {
    // Get the average duration and interarrival time from the config (or default to 0 if missing)
    double meanDuration = (config['mean-duration'] as num?)?.toDouble() ?? 0.0;
    double meanInterarrivalTime = (config['mean-interarrival-time'] as num?)?.toDouble() ?? 0.0;
    
    
    print('Creating StochasticProcess with mean-duration: $meanDuration, mean-interarrival-time: $meanInterarrivalTime');
    
    
    durationDist = ExpDistribution(mean: meanDuration);
    interarrivalDist = ExpDistribution(mean: meanInterarrivalTime);
  }

  // Generates events at random intervals, with random durations.
  @override
  List<Event> generateEvents() {
    List<Event> events = [];
    // Set the initial arrival time and the end time (after which no more events will be generated)
    double arrivalTime = (config['first-arrival'] as num?)?.toDouble() ?? 0.0;
    double end = (config['end'] as num?)?.toDouble() ?? double.infinity;
    
    //print statement showing when events will start and stop being generated.
    print('Generating events starting at $arrivalTime and ending at $end');
    
    // Keep generating events as long as the arrival time is before the end time.
    while (arrivalTime < end) {
      
      events.add(Event(
        name,
        arrivalTime,
        durationDist.next()  
      ));
      
      // Move to the next arrival time by adding a random interarrival time.
      arrivalTime += interarrivalDist.next();
    }
    return events;  // Return the list of randomly generated events
  }
}
