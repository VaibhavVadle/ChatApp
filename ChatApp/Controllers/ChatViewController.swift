import FirebaseAuth
import FirebaseFirestore
import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!

    let db = Firestore.firestore()

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        navigationItem.title = K.appName
        tableView.register(
            UINib(nibName: K.cellNibName, bundle: nil),
            forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }

    func loadMessages() {

        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
                self.messages = []
                if let e = error {
                    print("Error while fetching messages \(e)")
                } else {
                    if let snapshotDocument = querySnapshot?.documents {
                        for doc in snapshotDocument {
                            let data = doc.data()
                            if let messageSender = data[K.FStore.senderField]
                                as? String,
                                let messageBody = data[K.FStore.bodyField]
                                    as? String
                            {
                                let newMessage = Message(
                                    sender: messageSender, body: messageBody)
                                self.messages.append(newMessage)

                                // Note: To add DipatchQueue.main.async if UI is update in background process such as this closure
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(
                                        row: self.messages.count - 1, section: 0
                                    )
                                    self.tableView.scrollToRow(
                                        at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text,
            let messageSender = Auth.auth().currentUser?.email
        {
            db.collection(K.FStore.collectionName).addDocument(
                data: [
                    K.FStore.senderField: messageSender,
                    K.FStore.bodyField: messageBody,
                    K.FStore.dateField: Date().timeIntervalSince1970,
                ]) { error in
                    if let e = error {
                        print("Error adding document: \(e)")
                    } else {
                        print("Successfully added document!")
                        DispatchQueue.main.async {
                            self.messageTextfield.text = ""
                        }
                    }
                }
        }
    }

    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let message = messages[indexPath.row]

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: K.cellIdentifier, for: indexPath)
            as! MessageCell
        cell.label?.text = message.body
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(
                named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(
                named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}

// Used for user interaction on cell
//extension ChatViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
//}
