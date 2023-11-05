//
//  ViewController.swift
//  SoundBoard
//
//  Created by Elvis Quecara Cruz on 4/11/23.
//

import UIKit
import AVFoundation

import MediaPlayer


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    
    var tiempoDeGrabacion: TimeInterval?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let volumeView = MPVolumeView(frame: CGRect(x: 16, y: 100, width: 200, height: 50))
                view.addSubview(volumeView)
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try
            context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
            let grabacion = grabaciones[indexPath.row]
            let minutos = Int(grabacion.duracion) / 60
            let segundos = Int(grabacion.duracion) % 60
            cell.textLabel?.text = "\(grabacion.nombre ?? "") - \(minutos):\(segundos)"
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        do{
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
        
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                grabaciones = try
                context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            }catch{}
        }
    }
}
