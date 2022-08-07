//
//  File.swift
//
//
//  Created by Aleksandr Solovyev on 07.08.2022.
//

import Foundation

public typealias VMP = ViewModelProtocol

// MARK: - Right

public class ComboMainModel<Main: VMP>: BaseViewModel<Main.View>, Combo
{

}

public class ComboRightModel<Main: VMP, RightModel: VMP>:
   BaseViewModel<Main.View>, ComboRight
{
   public let rightModel
}

public class ComboRightDownModel<Main: VMP, RightModel: VMP, DownModel: VMP>:
   ComboRightModel<Main, RightModel>, ComboDown
{
   public let downModel = DownModel()
}

public class ComboRightRightModel<Main: VMP, RightModel: VMP, DownModel: VMP>:
   ComboRightModel<Main, RightModel>, ComboRight2
{
   public let right2Model: RightModel = .init()
}

public class ComboRightDownRightModel<Main: VMP, RightModel: VMP, DownModel: VMP, Right2Model: VMP>:
   ComboRightDownModel<Main, RightModel, DownModel>, ComboRight2
{
   public let right2Model: RightModel = .init()
}

public class ComboRightRightDownModel<Main: VMP, RightModel: VMP, DownModel: VMP, Right2Model: VMP>:
   ComboRightDownModel<Main, RightModel, DownModel>, ComboRight2
{
   public let right2Model: RightModel = .init()
}

public class ComboRightDownDownModel<Main: VMP, RightModel: VMP, DownModel: VMP, Down2Model: VMP>:
   ComboRightDownModel<Main, RightModel, DownModel>, ComboDown2
{
   public let down2Model: Down2Model = .init()
}

// MARK: - Down

public class ComboDownModel<Main: VMP, DownModel: VMP>:
   BaseViewModel<Main.View>, ComboDown
{
   public let downModel = DownModel()
}

// public class ComboRightLeftModel<Main: VMP, RightModel: VMP, LeftModel: VMP>:
//   ComboRightModel<Main, RightModel>, ComboLeft
// {
//   public let leftModel: LeftModel = .init()
// }

// public class ComboRightTopModel<Main: VMP, RightModel: VMP, TopModel: VMP>:
//   ComboRightModel<Main, RightModel>, ComboTop
// {
//   public let topModel: TopModel = .init()
// }

// public class ComboRightDownLeftModel<Main: VMP, RightModel: VMP, DownModel: VMP, LeftModel: VMP>:
//   ComboRightDownModel<Main, RightModel, DownModel>, ComboLeft
// {
//   public let leftModel: LeftModel = .init()
// }

// public class ComboRightDownTopModel<Main: VMP, RightModel: VMP, DownModel: VMP, TopModel: VMP>:
//   ComboRightDownModel<Main, RightModel, DownModel>, ComboTop
// {
//   public let topModel: TopModel = .init()
// }

// public class ComboDownLeftModel<Main: VMP, DownModel: VMP, LeftModel: VMP>:
//   ComboDownModel<Main, DownModel>, ComboLeft
// {
//   public var leftModel: LeftModel = .init()
// }
//
// public class ComboDownTopModel<Main: VMP, DownModel: VMP, TopModel: VMP>:
//   ComboDownModel<Main, DownModel>, ComboTop
// {
//   public var topModel: TopModel = .init()
// }

// public class ComboDownLeftTopModel<Main: VMP, DownModel: VMP, TopModel: VMP>:
//   ComboDownModel<Main, DownModel>, ComboTop
// {
//   public  var topModel: TopModel = .init()
// }

// MARK: - Left

// public class ComboLeftModel<Main: VMP, LeftModel: VMP>:
//   BaseViewModel<Main.View>, ComboLeft
// {
//   public let leftModel = LeftModel()
// }
//
// public class ComboLeftTopModel<Main: VMP, LeftModel: VMP, TopModel: VMP>:
//   ComboLeftModel<Main, LeftModel>, ComboTop
// {
//   public let topModel: TopModel = .init()
// }

// MARK: - Up

// public class ComboTopModel<Main: VMP, TopModel: VMP>:
//   BaseViewModel<Main.View>, ComboTop
// {
//   public let topModel = TopModel()
// }

// MARK: - Full Combo

// public class ComboFullModel<Main: VMP, RightModel: VMP, DownModel: VMP, LeftModel: VMP, TopModel: VMP>:
//   ComboRightDownTopModel<Main, RightModel, DownModel, TopModel>, ComboLeft
// {
//   public var leftModel: LeftModel = .init()
// }
