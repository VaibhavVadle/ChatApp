import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = K.appName
//        titleLabel.text = ""
//        var charIndex = 0.0
//        let titleText = K.appName
//        for letter in titleText {
//            Timer.scheduledTimer(
//                withTimeInterval: 0.1 * charIndex, repeats: false
//            ) { timer in
//                self.titleLabel.text?.append(letter)
//            }
//            charIndex += 1
//        }
    }
}
