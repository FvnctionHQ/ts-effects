# TSEffects

Drop-in audio effects module. Powered by AudioKit. You can easily add more effects, pull requests are encouraged :) 

## Installation
To add TSEffects to your Xcode project, select File -> Swift Packages -> Add Package Depedancy. Enter `https://github.com/FvnctionHQ/ts-effects`


## Api

```
public protocol TSEffectsModuleInterface {
 
    func close()
    func present(in controller: UIViewController, animated: Bool)
    
}

public protocol TSEffectsModuleDelegate: AnyObject {
    
    func TSEffectsModuleDidProvideRender(module:TSEffects, resultURL: URL)
    func TSEffectsModuleDidRequstShowLoadingDismiss(module: TSEffects)
    func TSEffectsModuleDidRequstShowLoading(module: TSEffects)
    
}
```
