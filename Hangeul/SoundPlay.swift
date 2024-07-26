//
//  SoundPlay.swift
//  Hangeul
//
//  Created by 이주화 on 2022/04/26.
//

import UIKit
import AVFoundation

class SoundPlayer: NSObject {

    let sound_uri=NSDataAsset(name: "uri sound")!.data
    let sound_sarang=NSDataAsset(name: "sarang sound")!.data
    let sound_useum=NSDataAsset(name: "useum sound")!.data
    let sound_annyeong=NSDataAsset(name: "annyeong sound")!.data
    let sound_hangeul=NSDataAsset(name: "hangeul sound")!.data
    let sound_clear=NSDataAsset(name: "clear sound")!.data
    let sound_u=NSDataAsset(name: "u sound")!.data
    let sound_ri=NSDataAsset(name: "ri sound")!.data
    let sound_dding=NSDataAsset(name: "dding sound")!.data
    let sound_next=NSDataAsset(name: "next sound")!.data
    let sound_sa=NSDataAsset(name: "sa sound")!.data
    let sound_ut=NSDataAsset(name: "ut sound")!.data
    let sound_an=NSDataAsset(name: "an sound")!.data
    let sound_han=NSDataAsset(name: "han sound")!.data
    var music_player:AVAudioPlayer!

    
    func uri_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_uri)
            music_player.play()
        }catch{
            print(".")
        }
    }
    func sarang_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_sarang)
            music_player.play()
        }catch{
            print(".")
        }

    }
        
    func useum_play(){

            do{
                music_player=try AVAudioPlayer(data:sound_useum)
                music_player.play()
            }catch{
                print(".")
            }

    }
        
    func annyeong_play(){

                do{
                    music_player=try AVAudioPlayer(data:sound_annyeong)
                    music_player.play()
                }catch{
                    print(".")
                }

    }
        
    func hangeul_play(){

                do{
                    music_player=try AVAudioPlayer(data:sound_hangeul)
                    music_player.play()
                }catch{
                    print(".")
                }

    }
    func clear_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_clear)
            music_player.play()
        }catch{
            print(".")
        }
    }
    func u_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_u)
            music_player.play()
        }catch{
            print(".")
        }
    }
    func ri_play(){

        do{
            music_player=try AVAudioPlayer(data:sound_ri)
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
    func sa_play(){

            do{
                music_player=try AVAudioPlayer(data:sound_sa)
                music_player.play()
            }catch{
                print(".")
            }

    }
    func ut_play(){

            do{
                music_player=try AVAudioPlayer(data:sound_ut)
                music_player.play()
            }catch{
                print(".")
            }

    }
    func an_play(){

            do{
                music_player=try AVAudioPlayer(data:sound_an)
                music_player.play()
            }catch{
                print(".")
            }

    }
    func han_play(){

            do{
                music_player=try AVAudioPlayer(data:sound_han)
                music_player.play()
            }catch{
                print(".")
            }

    }

    func stopAllMusic (){
        music_player?.stop()
    }
}

