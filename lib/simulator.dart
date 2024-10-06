// Importing process.dart here
import 'processes.dart';


//it is a priority queue which ensures that elements (like events) are processed based on their importance or timing.
class PriorityQueue<E extends Comparable<E>> {
  final List<E> _heap = [];  // A list to hold the elements in the queue

  //Function to add an element to the queue
  void add(E element) {
    _heap.add(element);  // Add element to the list
    _siftUp(_heap.length - 1);  
  }

  // function to remove the element with the highest priority it isusually the first one 
  E removeFirst() {
    if (_heap.isEmpty) throw StateError('Queue is empty');  // If the list is empty, throw an error
    if (_heap.length == 1) return _heap.removeLast();  
    final E result = _heap[0];  
    _heap[0] = _heap.removeLast();  
    _siftDown(0);  
    return result;  
  }

  // function to add multiple elements to the queue
  void addAll(Iterable<E> elements) {
    elements.forEach(add);  // one at a time
  }

  // Check if the queue is empty
  bool get isEmpty => _heap.isEmpty;

  // This function moves an element up the queue to maintain the order
  void _siftUp(int index) {
    final E element = _heap[index]; 
    while (index > 0) {
      int parentIndex = (index - 1) ~/ 2;  
      E parent = _heap[parentIndex];  
      if (element.compareTo(parent) >= 0) break;  
      _heap[index] = parent;  
      index = parentIndex;  // Update the index to the parent's position
    }
    _heap[index] = element;  
  }

  // This function moves an element down the queue to maintain the order
  void _siftDown(int index) {
    final int length = _heap.length;  //Get the size of the list
    final E element = _heap[index];  //Get the current element
    while (true) {
      int childIndex = index * 2 + 1;  
      if (childIndex >= length) break; 
      E child = _heap[childIndex];  
      int rightChildIndex = childIndex + 1;  
      if (rightChildIndex < length) {
        E rightChild = _heap[rightChildIndex];  
        if (rightChild.compareTo(child) < 0) {  
          childIndex = rightChildIndex;
          child = rightChild;
        }
      }
      if (element.compareTo(child) <= 0) break;  // If the element is in the correct position then stop
      _heap[index] = child;  
      index = childIndex;  
    }
    _heap[index] = element;  
  }
}

// Tthis calss handles processes and events.
class Simulator {
  final Map<String, Process> processes = {};  
  final PriorityQueue<Event> eventQueue = PriorityQueue<Event>();  
  final bool verbose; 
  double currentTime = 0;  
  List<Event> completedEvents = [];  // A list of events that have finished

//  yaml file is stored as a map
  Simulator(Map config, {this.verbose = false}) {
    _initializeProcesses(config);  // Call the function 
  }

  // it initializes the process of comnfig
  void _initializeProcesses(Map config) {
    config.forEach((name, processConfig) {
      switch (processConfig['type']) {
        case 'singleton':  // If it is  a one-time process
          processes[name] = SingletonProcess(name, processConfig);
          break;
        case 'periodic':  // If it is a process that repeats
          processes[name] = PeriodicProcess(name, processConfig);
          break;
        case 'stochastic':  // If itis a random process
          processes[name] = StochasticProcess(name, processConfig);
          print('Nikhil simulator at 83: ${processes[name]}');
          break;
        default:
          throw ArgumentError('Unknown process type: ${processConfig['type']}');  // Throw error if type is unknown
      }
      eventQueue.addAll(processes[name]!.generateEvents());  // Add all events for the process to the queue
    });
  }

  // This is the main function it runs the simulation
  void run() {
    print('# Simulation trace\n'); 
    while (!eventQueue.isEmpty) {
      Event event = eventQueue.removeFirst();

      // Wait time calculelation
      double waitTime = currentTime > event.arrivalTime ? currentTime - event.arrivalTime : 0;

      //Update time
      currentTime = currentTime > event.arrivalTime ? currentTime : event.arrivalTime;

      print(
        't=${currentTime.toStringAsFixed(0)}: ${event.processName}, '
        'duration ${event.duration.toStringAsFixed(0)} started '
        '(arrived @ ${event.arrivalTime.toStringAsFixed(0)}, '
        '${waitTime == 0 ? 'no wait' : 'waited ${waitTime.toStringAsFixed(0)}'})'
      );

      // Set the event's start time to the current time
      event.startTime = currentTime;

      // Move the current time forward by the event's duration
      currentTime += event.duration;

      // Add the event to the list of completed events
      completedEvents.add(event);
    }
    print('\n--------------------------------------------------------------\n');
  }

  // This function prints a report of the simulation after it finishes
  void printReport() {
    print('\n# Per-process statistics\n');  
    processes.forEach((name, process) {
      var processEvents = completedEvents.where((e) => e.processName == name);  
      var totalWaitTime = processEvents.fold(0.0, (sum, e) => sum + (e.startTime - e.arrivalTime)); 
      var avgWaitTime = processEvents.isNotEmpty ? totalWaitTime / processEvents.length : 0.0;  

      // Print out the stats 
      print('$name:');
      print('  Events generated:  ${processEvents.length}');
      print('  Total wait time:   ${totalWaitTime.toStringAsFixed(2)}');
      print('  Average wait time: ${avgWaitTime.toStringAsFixed(2)}\n');
    });

    // Print summary statistics for the entire simulation similar to README.MD 
    print('--------------------------------------------------------------\n');
    print('# Summary statistics\n');
    var totalWaitTime = completedEvents.fold(0.0, (sum, e) => sum + (e.startTime - e.arrivalTime));  // Total wait time for all events
    var avgWaitTime = completedEvents.isNotEmpty ? totalWaitTime / completedEvents.length : 0.0;  // Average wait time for all events

    print('Total num events:  ${completedEvents.length}');
    print('Total wait time:   ${totalWaitTime.toStringAsFixed(2)}');
    print('Average wait time: ${avgWaitTime.toStringAsFixed(2)}');
  }
}
