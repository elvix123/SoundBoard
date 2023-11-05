    //
    //  SoundViewController.swift
    //  SoundBoard
    //
    //  Created by Elvis Quecara Cruz on 4/11/23.
    //

    import UIKit
    import AVFoundation
    import MediaPlayer
    import AVFoundation

    class SoundViewController: UIViewController {
        
        
        
       
        
        @IBOutlet weak var grabarButton: UIButton!
        @IBOutlet weak var reproducirButton: UIButton!
        @IBOutlet weak var nombreTextField: UITextField!
        @IBOutlet weak var agregarButton: UIButton!
        @IBOutlet weak var tiempoLabel: UILabel! // Añade el UILabel en tu vista y conecta este outlet
        @IBOutlet weak var volumenSlider: UISlider!

        var grabarAudio: AVAudioRecorder?
        var reproducirAudio: AVAudioPlayer?
        var audioURL: URL?
        var tiempoTranscurrido: TimeInterval = 0
        var timer: Timer?
       

        
        @IBAction func grabarTapped(_ sender: Any) {
            if grabarAudio!.isRecording {
                grabarAudio?.stop()
                grabarButton.setTitle("GRABAR", for: .normal)
                reproducirButton.isEnabled = true
                agregarButton.isEnabled = true
                timer?.invalidate() // Detén el Timer cuando se detiene la grabación
            } else {
                grabarAudio?.record()
                grabarButton.setTitle("DETENER", for: .normal)
                reproducirButton.isEnabled = false
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    self?.tiempoTranscurrido += 1
                    let minutos = Int(self?.tiempoTranscurrido ?? 0) / 60
                    let segundos = Int(self?.tiempoTranscurrido ?? 0) % 60
                    self?.tiempoLabel.text = String(format: "%02d:%02d", minutos, segundos)
                    
                    
                    
                }
            }
        }
        
        @IBAction func reproducirTapped(_ sender: Any) {
            guard let audioURL = audioURL else {
                print("URL de audio no válida.")
                return
            }

            do {
                reproducirAudio = try AVAudioPlayer(contentsOf: audioURL)
                reproducirAudio?.prepareToPlay()
                reproducirAudio?.volume = volumenSlider.value // Asegúrate de configurar el volumen aquí
                reproducirAudio?.play()
                print("Reproduciendo")
            } catch {
                print("Error al reproducir audio")
            }
        }

        @IBAction func agregarTapped(_ sender: Any) {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let grabacion = Grabacion(context: context)
            grabacion.nombre = nombreTextField.text
            grabacion.audio = NSData(contentsOf: audioURL!)! as Data
            grabacion.duracion = tiempoTranscurrido 
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController!.popViewController(animated: true)
            
        }
        
        @objc func volumenSliderChanged() {
            reproducirAudio?.volume = volumenSlider.value
        }

        
        override func viewDidLoad() {
            super.viewDidLoad()
            configurarGrabacion()
            reproducirButton.isEnabled = false
            agregarButton.isEnabled = false
           
            
            volumenSlider.value = reproducirAudio?.volume ?? 1.0

                // Agrega un target para manejar cambios en el valor del slider
                volumenSlider.addTarget(self, action: #selector(volumenSliderChanged), for: .valueChanged)

            
        }
        
        
        
        
       
        
       
        
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            timer?.invalidate() // Detén el Timer cuando se sale de la vista
        }
        
        func configurarGrabacion() {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
                try session.overrideOutputAudioPort(.speaker)
                try session.setActive(true)
                
                let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let pathComponents = [basePath, "audio.m4a"]
                audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
                
                print("*************************")
                print(audioURL!)
                print("*************************")
                
                var settings: [String: AnyObject] = [:]
                settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
                settings[AVSampleRateKey] = 44100.0 as AnyObject?
                settings[AVNumberOfChannelsKey] = 2 as AnyObject?
                
                grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
                grabarAudio!.prepareToRecord()
            } catch let error as NSError {
                print(error)
            }
        }
    }

