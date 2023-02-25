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
public protocol TaskProtocol: AnyObject, TaskCompletableContainer, Cancellable {
    func start()
    func cancel()
}

@available(iOS 13.0, *)
public protocol TaskCompletable {
    func finish()
    func cancel(task: TaskProtocol)
}

@available(iOS 13.0, *)
public class TaskQueue {
    
    public enum TaskInterval {
        case interval(Double)
        case randomRange(Range<Double>)
        
        var delay: Double {
            let delay: Double
            switch self {
            case .interval(let value):
                delay = value
            case .randomRange(let range):
                delay = range.random
            }
            return delay
        }
    }
    
    public var autoStart: Bool = true
    public var taskInterval: TaskInterval = .interval(0)
    public var laterTaskInterval: TaskInterval = .interval(0)
    
    private var taskGroup: [TaskProtocol] = []
    private var laterTaskGroup: [TaskProtocol] = []
    private let taskComplete = TaskComplete()
    private var isStartingTask: Bool = false
    private let bag = DisposeBag()
    public private(set) var waitFinished = false
    private var currentTask: TaskProtocol?
    private var timer: Timer?
    private var nextIsNormalTask: Bool {
        return !taskGroup.isEmpty
    }
    private let lock = NSLock()
    
    public init() {
        taskComplete.finishSubject.sink { [weak self] in
            guard let self = self else { return }
            self.currentTask = nil
            self.waitFinished = false
            self.startTimer()
        }.dispose(by: bag)
        
        taskComplete.cancelSubject.sink { [weak self] task in
            guard let self else { return }
            if let index = self.taskGroup.firstIndex(where: { $0 === task }) {
                self.taskGroup.remove(at: index)
            }
            if let index = self.laterTaskGroup.firstIndex(where: { $0 === task }) {
                self.laterTaskGroup.remove(at: index)
            }
        }.dispose(by: bag)
    }
    
    public func appendTask(task: TaskProtocol, laterTask: Bool = false) {
        appendTasks(tasks: [task], laterTask: laterTask)
    }
    
    public func appendTasks(tasks: [TaskProtocol], laterTask: Bool = false) {
        lock.withLock {
            if laterTask {
                laterTaskGroup.append(contentsOf: tasks)
            } else {
                taskGroup.append(contentsOf: tasks)
            }
        }
        if autoStart && (isStartingTask == false || waitFinished == false) {
            startTask()
        }
    }
    
    public func startTask() {
        isStartingTask = true
        _startTask()
        
    }
    
    private func _startTask() {
        lock.withLock {
            cancelTimer()
            guard isStartingTask, !waitFinished else { return }
            let firstTask: TaskProtocol?
            if let task = taskGroup.first {
                taskGroup.removeFirst()
                firstTask = task
            } else if let task = laterTaskGroup.first {
                laterTaskGroup.removeFirst()
                firstTask = task
            } else {
                firstTask = nil
            }
            guard var firstTask else { return }
            currentTask = firstTask
            waitFinished = true
            DispatchQueue.global().async {
                firstTask.taskCompletable = self.taskComplete
                firstTask.start()
            }
        }
    }
    
    public func stopTask() {
        isStartingTask = false
    }
    
    private func startTimer() {
        let delay = nextIsNormalTask ? taskInterval.delay : laterTaskInterval.delay
        if delay == 0 {
            /*
             重新开一个线程，避免死锁
             */
            DispatchQueue.global().async {
                self._startTask()
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] _ in
                self?._startTask()
            })
        }
    }
    
    private func cancelTimer() {
        timer?.fireDate = .distantFuture
        timer?.invalidate()
        timer = nil
    }
    
}

@available(iOS 13.0, *)
private class TaskComplete: TaskCompletable {

    let finishSubject = PassthroughSubject<Void, Never>()
    let cancelSubject = PassthroughSubject<TaskProtocol, Never>()
    
    func cancel(task: TaskProtocol) {
        cancelSubject.send(task)
    }
    
    func finish() {
        finishSubject.send()
    }
    
}
