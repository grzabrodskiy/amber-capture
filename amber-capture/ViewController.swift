import UIKit
import AVFoundation


class ViewController: UIViewController, VideoFeedDelegate {


    @IBOutlet var previewImage :UIImageView!
    @IBOutlet var captureButton: UIButton!
    @IBOutlet var cameraView: UIView!
    @IBOutlet var imageSize: UILabel!

    
    var videoFeed: VideoFeed?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // end session
        videoFeed?.stopSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // request camera access
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] granted in
            guard granted != false else {
                // TODO: show UI stating camera cannot be used, update in settings app...
                print("Camera access denied")
                return
            }
            DispatchQueue.main.async {

                if self?.videoFeed == nil {
                    // video access was enabled so setup video feed
                    self?.videoFeed = VideoFeed(delegate: self)
                } else {
                    // video feed already available, restart session...
                    self?.videoFeed?.startSession()
                }

            }
        }
    }

    // MARK: VideoFeedDelegate
    func videoFeedSetup(with layer: AVCaptureVideoPreviewLayer) {

        // set the layer size
        layer.frame = cameraView.layer.bounds

        // add to view
        cameraView.layer.addSublayer(layer)
    }

    func processVideoSnapshot(_ image: UIImage?) {

        
        // validate
        guard let image = image else {
            return
        }

        // Save image

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: AppDelegate.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "PreviewViewController")
        previewImage.image = image
        
        let h  = Int(image.size.height * image.scale)
        let w  = Int(image.size.width * image.scale)
        let s = "Image Size: \(h) x \(w)"
        print(s)
        imageSize.text = s
        navigationController?.pushViewController(vc, animated: true)

    }

    @IBAction func captureButtonTapped(_ sender: Any){

        // trigger photo capture from video feed...
        // this will trigger a callback to the function above with the captured image
        videoFeed?.capturePhoto()
    }
}
