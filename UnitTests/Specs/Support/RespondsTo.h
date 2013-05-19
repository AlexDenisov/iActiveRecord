//
//  RespondsTo.h
//
//  Created by Alex Denisov on 21.02.13.
//

#pragma once

#import <Foundation/Foundation.h>
#import <Cedar-iOS/Cedar-iOS.h>

namespace Cedar { namespace Matchers {
    
    class RespondsTo : public Base<> {
    private:
        RespondsTo & operator=(const RespondsTo &);
        
    public:
        explicit RespondsTo(const SEL selector);
        RespondsTo(NSString * selectorName);
        ~RespondsTo();
        
        bool matches(const id) const;
        
    protected:
        virtual NSString * failure_message_end() const;
        
    private:
        const SEL expectedSelector_;
    };
    
    inline RespondsTo responds_to(const SEL selector) {
        return RespondsTo(selector);
    }
    
    inline RespondsTo responds_to(NSString *selectorName) {
        return RespondsTo(NSSelectorFromString(selectorName));
    }
    
    inline RespondsTo::RespondsTo(const SEL selector)
    : Base<>(), expectedSelector_(selector) {}
    
    inline RespondsTo::RespondsTo(NSString *selectorName)
    : Base<>(), expectedSelector_(NSSelectorFromString(selectorName)) {}
    
    inline RespondsTo::~RespondsTo() {}
    
    inline /*virtual*/ NSString * RespondsTo::failure_message_end() const {
        return [NSString stringWithFormat:@"respond <%@> selector",
                NSStringFromSelector(expectedSelector_)];
    }

#pragma mark Generic
    inline bool RespondsTo::matches(const id actualValue) const {
        return [actualValue respondsToSelector:expectedSelector_];
    }

}}
