//
//  PlaceholderTextView.m
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import "PlaceholderTextView.h"
#import "NSString+Additions.h"
#import "UIColor+Additions.h"

#define placefonttag 1001
@interface PlaceholderTextView ()
@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, strong) UILabel *wordCountLabel;

-(void)textChanged:(NSNotification*)notification;
@end

@implementation PlaceholderTextView
@synthesize placeholderLabel;
@synthesize placeholder = _placeholder;
@synthesize placeholderColor = _placeholderColor;
@synthesize placeholderFont = _placeholderFont;
-(void)setup
{
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    self.placeholder = [NSString string];
    self.placeholderFont = self.font;
    self.maxLength = 100;
    self.showWordCountLabel = NO;
    [self addSubview:self.wordCountLabel];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

-(void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    [self setNeedsDisplay];
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextView properties
- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    //需要解释
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:placefonttag] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:placefonttag] setAlpha:0];
    }
    if(self.showWordCountLabel){
        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/%ld",(unsigned long)self.text.length,(long)self.maxLength];
        [self updateWordCountLabelFrame];
    }
    
}

- (void)updateWordCountLabelFrame
{
    if(self.text.length == 0){
        _wordCountLabel.hidden = YES;
    }else{
        _wordCountLabel.hidden = NO;
    }
    
    if(self.text.length > self.maxLength){
        self.wordCountLabel.textColor = [UIColor redColor];
    }else{
        self.wordCountLabel.textColor = [UIColor colorFromHexCode:@"999999"];
    }
    
    CGSize size = [self.wordCountLabel.text textSizeWithFont:self.wordCountLabel.font];
    [self.wordCountLabel setFrame:CGRectMake(self.frame.size.width - size.width, self.frame.size.height - size.height, size.width, size.height)];
}



- (UILabel *)wordCountLabel
{
    if(!_wordCountLabel){
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _wordCountLabel.font = [UIFont systemFontOfSize:13];
        _wordCountLabel.textColor = [UIColor colorFromHexCode:@"999999"];
    }
    return _wordCountLabel;
}


- (void)setShowWordCountLabel:(BOOL)showWordCountLabel
{
    _showWordCountLabel = showWordCountLabel;
    if(showWordCountLabel){
        [self updateWordCountLabelFrame];
        self.wordCountLabel.hidden = NO;
    }else{
        self.wordCountLabel.hidden = YES;
    }
   
}


- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( placeholderLabel == nil )
        {
            placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,5,self.bounds.size.width,0)];
            placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            placeholderLabel.numberOfLines = 0;
            placeholderLabel.font = self.placeholderFont;
            placeholderLabel.backgroundColor = [UIColor clearColor];
            placeholderLabel.textColor = self.placeholderColor;
            placeholderLabel.alpha = 0;
            placeholderLabel.tag = placefonttag;
            [self addSubview:placeholderLabel];
        }
        
        placeholderLabel.text = [self.placeholder stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [placeholderLabel sizeToFit];
        [self sendSubviewToBack:placeholderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:placefonttag] setAlpha:1];
    }
   self.textContainerInset = UIEdgeInsetsMake(5, 2, 0, 0);
    [super drawRect:rect];
}

//隐藏键盘，实现UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
