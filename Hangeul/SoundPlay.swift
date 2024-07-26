//
//  SoundPlay.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject {


    let sound_clear=NSDataAsset(name: "clear sound")!.data
    let sound_dding=NSDataAsset(name: "dding sound")!.data
    let sound_next=NSDataAsset(name: "next sound")!.data
    var music_player:AVAudioPlayer!


    func clear_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_clear)
            music_player.play()
        }catch{
            print(".")
        }
    }

    func dding_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_dding)
            music_player.play()
        }catch{
            print(".")
        }
    }
    
    func next_play(){

        do{
            music_player = try AVAudioPlayer(data:sound_next)
            music_player.play()
        }catch{
            print(".")
        }
    }

    func stopAllMusic (){
        music_player?.stop()
    }
}

