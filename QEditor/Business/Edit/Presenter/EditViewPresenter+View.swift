//
//  EditViewPresenter+View.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/30.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

extension EditViewPresenter: EditViewOutput {
    
    func view(_ view: EditViewInput, didLoadSource urls: [URL]) {
        //交给Service处理成model
        let segments = urls.map { (url) -> CompositionVideoSegment in
            return CompositionVideoSegment(url: url)
        }
        project.addVideos(from: segments)
        toolView?.updateDuration(project.composition!.duration.seconds)
        playerView?.updateDuration(project.composition!.duration.seconds)
        //刷新视图
        refreshView()
    }
    
    func viewShouldExportVideo(_ view: EditViewInput) {
        let url = URL(fileURLWithPath: String.qe.tmpPath() + String.qe.timestamp() + ".mp4")
        let vc = ExportViewController()
        vc.exporter = project.generateExporter(url: url)
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
    }
    
    func exportProject() -> CompositionProjectConfig {
        return project.exportProject()
    }
    
    func importProject(_ config: CompositionProjectConfig) {
        project.importProject(config: config)
        refreshView()
    }
    
}
