//
//  TaskQueue.swift
//  FXSwiftX
//
//  Created by aria on 2022/9/15.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public protocol TaskCompletableContainer {
  var taskCompletable: TaskCompletable? { set get }
}

@available(iOS 13.0, *)
public protocol TaskProtocol: TaskCompletableContainer {
  func start()
}

@available(iOS 13.0, *)
public protocol TaskCompletable: Cancellable {
  func finish()
}

@available(iOS 13.0, *)
public class TaskQueue {
  
  public enum TaskInterval {
    case interval(Double)
    case randomRange(Range<Double>)
  }
  
  public var autoStart: Bool = true
  public var taskInterval: TaskInterval = .interval(0)
  
  private var taskGroup: [TaskProtocol] = []
  private var laterTaskGroup: [TaskProtocol] = []
  private let taskComplete = TaskComplete()
  private var isStartingTask: Bool = false
  private let bag = DisposeBag()
  private var waitFinished = false
  private var currentTask: TaskProtocol?
  
  public init() {
    taskComplete.finishSubject.sink { [weak self] in
      guard let self = self else { return }
      self.currentTask = nil
      let delay: Double
      switch self.taskInterval {
      case .interval(let value):
        delay = value
      case .randomRange(let range):
        delay = range.random
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.waitFinished = false
        self._startTask()
      }
    }.dispose(by: bag)
  }
  
  public func appendTask(task: TaskProtocol, laterTask: Bool = false) {
    appendTasks(tasks: [task], laterTask: laterTask)
  }
  
  public func appendTasks(tasks: [TaskProtocol], laterTask: Bool = false) {
    if laterTask {
      laterTaskGroup.append(contentsOf: tasks)
    } else {
      taskGroup.append(contentsOf: tasks)
    }
    if autoStart {
      startTask()
    }
  }
  
  public func startTask() {
    isStartingTask = true
    _startTask()
  }
  
  private func _startTask() {
    guard isStartingTask, !waitFinished else { return }
    let firstTask: TaskProtocol?
    if !taskGroup.isEmpty {
      firstTask = taskGroup.first
      taskGroup.removeFirst()
    } else if !laterTaskGroup.isEmpty {
      firstTask = laterTaskGroup.first
      laterTaskGroup.removeFirst()
    } else {
      firstTask = nil
    }
    guard var firstTask else { return }
    currentTask = firstTask
    firstTask.taskCompletable = taskComplete
    waitFinished = true
    firstTask.start()
  }
  
  public func stopTask() {
    isStartingTask = false
  }
  
}

@available(iOS 13.0, *)
private class TaskComplete: TaskCompletable {
  
  let finishSubject = PassthroughSubject<Void, Never>()
  
  func cancel() {
    finishSubject.send()
  }
  
  func finish() {
    finishSubject.send()
  }
  
}
