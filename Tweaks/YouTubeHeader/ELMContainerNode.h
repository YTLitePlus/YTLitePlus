#import "ELMElement.h"
#import "ASDisplayNode.h"

@interface ELMContainerNode : ASDisplayNode
@property (atomic, strong, readwrite) ELMElement *element;
- (void)addYogaChild:(id)child;
- (void)addSubnode:(id)subnode;
@end
