//
//  ConformsTo.h
//
//  Created by adenisov on 01.03.13.
//

#pragma once

#import <Foundation/Foundation.h>
#import <Cedar-iOS/Cedar-iOS.h>

namespace Cedar { namespace Matchers {
   
   class ConformsTo : public Base<> {
   private:
      ConformsTo & operator=(const ConformsTo &);
      
   public:
      explicit ConformsTo(Protocol *protocol);
      ConformsTo(NSString *protocolName);
      ~ConformsTo();
      
      bool matches(const id) const;
      
   protected:
      virtual NSString * failure_message_end() const;
      
   private:
       const Protocol *expectedProtocol_;
   };
   
   inline ConformsTo conforms_to(Protocol *protocol) {
      return ConformsTo(protocol);
   }
   
   inline ConformsTo conforms_to(NSString *protocolName) {
      return ConformsTo(protocolName);
   }
   
   inline ConformsTo::ConformsTo(Protocol *protocol)
   : Base<>(), expectedProtocol_(protocol) {}
   
   inline ConformsTo::ConformsTo(NSString *protocolName)
   : Base<>(), expectedProtocol_(NSProtocolFromString(protocolName)) { }
   
   inline ConformsTo::~ConformsTo() {}
   
   inline /*virtual*/ NSString * ConformsTo::failure_message_end() const {
      return [NSString stringWithFormat:@"conform <%@> protocol",
              NSStringFromProtocol((Protocol *)expectedProtocol_)];
   }
   
#pragma mark Generic
   inline bool ConformsTo::matches(const id actualValue) const {
      return [actualValue conformsToProtocol:(Protocol *)expectedProtocol_];
   }
   
}}
