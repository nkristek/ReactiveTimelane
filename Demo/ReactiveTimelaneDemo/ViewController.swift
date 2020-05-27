import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveTimelane

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let timedValueProducer: SignalProducer<(), Never> = {
        SignalProducer(value: ())
            .delay(5, on: QueueScheduler.main)
            .lane("Timed value producer")
    }()
    
    fileprivate enum Errors: Error {
        case somethingWentWrong
    }
    
    private let timedErrorProducer: SignalProducer<(), Errors> = {
        SignalProducer(value: ())
            .delay(5, on: QueueScheduler.main)
            .flatMap(.latest) { SignalProducer(error: .somethingWentWrong).lane("Inner error producer") }
            .lane("Timed error producer")
    }()
    
    private var (subscriptionLifetime, subscriptionToken) = Lifetime.make()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBindings()
    }
    
    private func setUpBindings() {
        reactive.lifetime += startValueProducerButton.reactive
            .mapControlEvents(.touchUpInside, { _ in () })
            .observeValues { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.subscriptionLifetime += strongSelf.timedValueProducer.start()
            }
        
        reactive.lifetime += startErrorProducerButton.reactive
            .mapControlEvents(.touchUpInside, { _ in () })
            .observeValues { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.subscriptionLifetime += strongSelf.timedErrorProducer.start()
            }
        
        reactive.lifetime += stopButton.reactive
            .mapControlEvents(.touchUpInside, { _ in () })
            .observeValues { [weak self] in
                guard let strongSelf = self else { return }
                (strongSelf.subscriptionLifetime, strongSelf.subscriptionToken) = Lifetime.make()
            }
    }
    
    // MARK: - View
    
    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            startValueProducerButton,
            startErrorProducerButton,
            stopButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()
    
    private let startValueProducerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start value producer", for: .normal)
        return button
    }()
    
    private let startErrorProducerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start error producer", for: .normal)
        return button
    }()
    
    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop all", for: .normal)
        return button
    }()
    
    private func setUpView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
}
