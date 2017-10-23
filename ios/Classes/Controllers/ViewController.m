//
//  ViewController.m
//  LXFDrawBoard
//
//  Created by LXF on 2017/7/6.
//  Copyright © 2017年 LXF. All rights reserved.
//

#import "ViewController.h"
#import "LXFDrawBoard.h"
#import "LXFRectangleBrush.h"
#import "LXFLineBrush.h"
#import "LXFArrowBrush.h"
#import "LXFTextBrush.h"
#import "LXFMosaicBrush.h"
#import <Photos/Photos.h>
#import "DesCollectionViewCell.h"


@interface ViewController () <LXFDrawBoardDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSIndexPath *markIndexpath;
    NSIndexPath *colorIndexpath;
}

/** board */
//@property (weak, nonatomic) IBOutlet LXFDrawBoard *board;
/** 描述 */
@property(nonatomic, copy) NSString *desc;


@property(nonatomic, copy) UIButton *moreButton;
@property (nonatomic,strong)UICollectionView *mainCollectionView;
@property (nonatomic,strong)LXFDrawBoard *board;

@property (nonatomic,strong)UICollectionView *colorCollectionView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.board.brush = [LXFRectangleBrush new];
//    self.board.brush = [LXFLineBrush new];
//    self.board.brush = [LXFArrowBrush new];
//    self.board.brush = [LXFTextBrush new];
    
    [self.view addSubview:self.board];
    self.board.delegate = self;
    UIButton *right_btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 60, 30, 44, 30)];
//    [right_btn setTitle:@"导出" forState:0];
    [right_btn setImage:[UIImage imageNamed:@"disk"] forState:0];

    
    [right_btn setTitleColor:TOP_Color forState:0];
    [right_btn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:right_btn];
    right_btn.titleLabel.textColor = TOP_Color;
    
    UIButton *left_btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 44, 30)];
//    [left_btn setTitle:@"导入" forState:0];
    [left_btn setImage:[UIImage imageNamed:@"矩形1拷贝"] forState:0];
    [left_btn addTarget:self action:@selector(getImageFromIpc) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:left_btn];
    [left_btn setTitleColor:TOP_Color forState:0];

    [self.view addSubview:self.mainCollectionView];
    [self.view addSubview:self.colorCollectionView];
    
    self.board.brush = [LXFPencilBrush new];

   
    _colorCollectionView.center  = CGPointMake(SCREEN_WIDTH - 25, SCREEN_HEIGHT/2);

}


-(LXFDrawBoard *)board
{
    if (!_board) {
        _board = [[LXFDrawBoard alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height)];
        _board.image = [UIImage imageNamed:@"LXFBG"];
    }return _board;
    
}


- (void)getImageFromIpc
{
    // 1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    // 2. 创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    /**
     typedef NS_ENUM(NSInteger, UIImagePickerControllerSourceType) {
     UIImagePickerControllerSourceTypePhotoLibrary, // 相册
     UIImagePickerControllerSourceTypeCamera, // 用相机拍摄获取
     }
     */
    // 3. 设置打开照片相册类型(显示所有相簿)
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // 照相机
    // ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    // 4.设置代理
    ipc.delegate = self;
    // 5.modal出这个控制器
    [self presentViewController:ipc animated:YES completion:nil];
}


#pragma mark -- <UIImagePickerControllerDelegate>--
// 获取图片后的操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 销毁控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
//    _board.contentMode = 2;
    // 设置图片
    _board.image = info[UIImagePickerControllerOriginalImage];;
}

- (void)save
{
    [self loadImageFinished:_board.image];
    
}

- (void)loadImageFinished:(UIImage *)image
{
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //      写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        NSLog(@"====%@",req);
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"success = %d, error = %@", success, error);
        if (success) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"The prompt message" message:@"Save success" preferredStyle:1];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:0 handler:^(UIAlertAction * _Nonnull action) {
            }];
            [vc addAction:action];
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
        
      
       
        
    }];
    
    
   
    
    
    
    
}






//
//UIGraphicsBeginImageContext(view.bounds.size);
//[view.layer renderInContext:UIGraphicsGetCurrentContext()];
//UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//UIGraphicsEndImageContext();
//
//
//这个方法生成的图片不太清晰  不过把这个方法修改一下  就可以了
//
//[objc] view plain copy
//#pragma mark 生成image
- (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size
{
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数 [UIScreen mainScreen].scale。
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}


- (IBAction)revoke {
    [self.board revoke];
}
- (IBAction)redo {
    [self.board redo];
}

- (IBAction)pencilBrush {
    self.board.brush = [LXFPencilBrush new];
}
- (IBAction)arrowBrush {
    self.board.brush = [LXFArrowBrush new];
}
- (IBAction)lineBrush {
    self.board.brush = [LXFLineBrush new];
}
- (IBAction)textBrush {
    self.board.brush = [LXFTextBrush new];
}
- (IBAction)rectangleBrush {
    self.board.brush = [LXFRectangleBrush new];
}
- (IBAction)mosaicBrush {
    self.board.brush = [LXFMosaicBrush new];
}

#pragma mark - LXFDrawBoardDelegate
- (NSString *)LXFDrawBoard:(LXFDrawBoard *)drawBoard textForDescLabel:(UILabel *)descLabel {
    
//    return [NSString stringWithFormat:@"我的随机数：%d", arc4random_uniform(256)];
    return self.desc;
}

- (void)LXFDrawBoard:(LXFDrawBoard *)drawBoard clickDescLabel:(UILabel *)descLabel {
    descLabel ? self.desc = descLabel.text: nil;
    [self alterDrawBoardDescLabel];
}

- (void)alterDrawBoardDescLabel {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加描述" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.desc = alertController.textFields.firstObject.text;
        [self.board alterDescLabel];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入";
        textField.text = self.desc;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}




#pragma mark
#pragma mark 懒加载collectionView
-(UICollectionView *)colorCollectionView
{
    if (!_colorCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _colorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 100, 40, SCREEN_HEIGHT * 2 / 3) collectionViewLayout:layout];
        _colorCollectionView.backgroundColor = [UIColor clearColor];

        _colorCollectionView.showsVerticalScrollIndicator = NO;
        _colorCollectionView.delegate = self;
        _colorCollectionView.dataSource = self;
        layout.scrollDirection = 0;
//        _colorCollectionView.backgroundColor = [UIColor orangeColor];
        _colorCollectionView.tag = 99;
        [_colorCollectionView registerNib:[UINib nibWithNibName:@"DesCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DesCollectionViewCell"];
    }
    return _colorCollectionView;
}




#pragma mark
#pragma mark 懒加载collectionView
-(UICollectionView *)mainCollectionView
{
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 70, self.view.bounds.size.width, 50) collectionViewLayout:layout];
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        layout.scrollDirection = 1;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        [_mainCollectionView registerNib:[UINib nibWithNibName:@"DesCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"DesCollectionViewCell"];
    }
    return _mainCollectionView;
}



#pragma mark
#pragma mark CollectionViewDelegate&&datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (collectionView.tag == 99) {
        return 9;
    }
    return 8;

}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    
    //    if (section == 0) {
    return 10;
    //    }
    //    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{

    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 15, 10, 15);
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView.tag == 99) {
        return CGSizeMake(30, 30);
    }
    return CGSizeMake(130, 38);
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DetailCollectionViewCellID = @"DesCollectionViewCell";
    DesCollectionViewCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailCollectionViewCellID forIndexPath:indexPath];
    if (collectionView.tag == 99) {
        cell.bgImageView.image = nil;
        cell.backgroundColor = UIColorWithRGB(arc4random() % 250, arc4random() % 250, arc4random() % 250);
        cell.contentLabel.hidden = YES;
        cell.layer.cornerRadius = 5;
        if (colorIndexpath == indexPath) {
            cell.alpha = 0.5;
        }else{
            cell.alpha = 1;
        }
        cell.layer.cornerRadius = 15;
      return cell;
    }
    [cell cellWithIndexPath:indexPath];
    
    if (markIndexpath == indexPath) {
        cell.alpha = 0.5;
    }else{
        cell.alpha = 1;
    }
    return cell;
}





-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (collectionView.tag  == 99) {
        UICollectionViewCell *cell  =[collectionView cellForItemAtIndexPath:indexPath];
        self.board.style.lineColor = cell.backgroundColor;
        colorIndexpath = indexPath;
//        [collectionView reloadData];
        return;
    }

    if (markIndexpath == indexPath) {
        return;
    }
    
    markIndexpath = indexPath;
    switch (indexPath.row) {
        case 0:
            [self.board revoke];

            break;
        case 1:
            [self.board redo];

            break;
        case 2:
            self.board.brush = [LXFPencilBrush new];

            break;
        case 3:
            self.board.brush = [LXFArrowBrush new];

            break;
        case 4:
            self.board.brush = [LXFLineBrush new];

            break;
        case 5:
            self.board.brush = [LXFTextBrush new];

            break;
        case 6:
            self.board.brush = [LXFRectangleBrush new];

            break;
        case 7:
            self.board.brush = [LXFMosaicBrush new];

            break;
            
        default:
            break;
    }
    [collectionView reloadData];
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
