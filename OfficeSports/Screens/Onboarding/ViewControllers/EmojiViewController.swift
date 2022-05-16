//
//  EmojiViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 12/05/2022.
//

import UIKit

final class EmojiViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        return UICollectionView.createCollectionView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension EmojiViewController: UICollectionViewDelegate {}
