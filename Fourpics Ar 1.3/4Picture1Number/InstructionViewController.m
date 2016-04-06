//
//  KNThirdViewController.m
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import "InstructionViewController.h"
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>

@interface InstructionViewController ()

@end

@implementation InstructionViewController
@synthesize helpLabel;
@synthesize dismissButton;
@synthesize resizeButton;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  dismissButton.layer.cornerRadius  = 10.0f;
  dismissButton.layer.masksToBounds = YES;
  resizeButton.layer.cornerRadius   = 10.0f;
  resizeButton.layer.masksToBounds  = YES;
}

- (void)viewDidUnload {
  [self setHelpLabel:nil];
  [self setDismissButton:nil];
  [self setResizeButton:nil];
  [super viewDidUnload];
}

- (void) SetTextForCategory :  (NSString *) category {
    if([category isEqualToString:@"تسلسل"]) {
        helpLabel.text = @"مجموعة أحجية مرحة وتصبح أكثر صعوبة: الصور الأربعة تصف تسلسلاً رياضياً مثال: ١،٣،٥،٧ الجواب التالي هو ٧ +٢ = ٩";
    }else if([category isEqualToString:@"منطق"]) {
        helpLabel.text = @"مجموعة أحجية تبدأ سهلة وتصبح أكثر صعوبة: الصور الأربعة لها تسلسل منطقي أو معادلة منطقية.";
    }else if([category isEqualToString:@"شيفرة"]) {
        helpLabel.text = @"مجموعة أحجية صعبة ومرحة: الصور الأربعة تشير إلى رقم، غالباً ما تحتاج للبحث على الانترنت";
    }else if([category isEqualToString:@"علم الفلك"]) {
        helpLabel.text = @"مجموعة أحجية تتطلب أيضاً بعض البحث، يرتبط الرقم المخفي بنظامنا الشمسي. اتبع الصور الأربعة.";
    }else if([category isEqualToString:@"معادلة"]) { 
        helpLabel.text = @" مجموعة أحجية مرحة وصعبة: تشير الصور الأربعة إلى وجود معادلة منطقية أو رياضية. معظم الوقت العمليات الحسابية تكون متطلبة مثل الجمع الضرب الطرح أو القسمة";
    }else if([category isEqualToString:@"وقت"] || [category isEqualToString:@"ساعة"]) {
        helpLabel.text = @"مجموعة أحجية تظهر تسلسلاً في الوقت، أو الوقت في جميع أنحاء العالم. ملاحظة للاعبين، تحتاج إلى استخدام ال \":\" في لوحة المفاتيح";
    }else if([category isEqualToString:@"أشكال"]) {
        helpLabel.text = @"مجموعة أحجية بسيطة وسهلة: الصور الأربعة تشير إلى وجود تسلسل من الأشكال";
    }else if([category isEqualToString:@"علم الهندسة"]) {
        helpLabel.text = @"مجموعة أحجية سهلة ومنطقية";
    }else if([category isEqualToString:@"رموز"]) {
        helpLabel.text = @"الصور الأربعة هي رموز ينبغي أن تشير إلى رقم واحد";
    }else if([category isEqualToString:@"سنة"]) {
        helpLabel.text = @"تتطلب بحثاً: الصور الأربعة تصف حدثاً شهيراً، الجواب هو عام هذا الحدث.";
    }else if([category isEqualToString:@"علم الاحياء"]) {
        helpLabel.text = @" الصور الأربعة تشير إلى رقم متصل بالبيولوجيا البشرية.";
    }else if([category isEqualToString:@" الفيزياء"] || [category isEqualToString:@"فيزياء"]) {
        helpLabel.text = @" ابحث عن المعادلة الفيزيائية التي تصفها الصور. ينبغي أن تقودك إلى الرقم الصحيح.";
    }else if([category isEqualToString:@"رياضة"]) {
        helpLabel.text = @"سجلات شهيرة لأهم الرياضيين في العالم";
    }else {
        helpLabel.text = @"";
    }
}
- (IBAction)dismissButtonDidTouch:(id)sender {

//  // Here's how to call dismiss button on the parent ViewController
//  // be careful with view hierarchy
//  UIViewController * parent = [self.view containingViewController];
//  if ([parent respondsToSelector:@selector(dismissSemiModalView)]) {
//    [parent dismissSemiModalView];
//  }
//    
    [self dismissSemiModalView];

}

- (IBAction)resizeSemiModalView:(id)sender {
    
  UIViewController * parent = [self.view containingViewController];
  if ([parent respondsToSelector:@selector(resizeSemiView:)]) {
    [parent resizeSemiView:CGSizeMake(320, arc4random() % 280 + 180)];
  }
}

@end
