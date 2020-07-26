print("---------------类型测试开始---------------")

local new = typesys.new

-- ObjClass类
local ObjClass = typesys.def.ObjClass{
	-- 私有字段 只有自己和子类能够访问
	_field0 = 0,

	-- 公有字段
	field1 = 1,
	field2 = false,
	field3 = "3",
}
function ObjClass:__ctor(field1,field2,field3) 
	self.field1 = field1
	self.field2 = field2
	self.field3 = field3
end

function ObjClass:Print()
	print("ObjClass 打印： ", self.field1,self.field2,self.field3)
end

-- SubObjClass类 继承 ObjClass类
local SubObjClass = typesys.def.SubObjClass{
	-- 私有字段 只有自己和子类能访问
	__super = ObjClass,

	-- 公有字段
	field4 = 4,
	field5 = "5",
	field6 = false,
	field7 = {}
}

function SubObjClass:__ctor(field4,field5,field6,field7) 
	self.field4 = field4
	self.field5 = field5
	self.field6 = field6
	self.field7 = field7

	-- 父类构造 子类可以访问父类的私有方法
	self.__super:__ctor(111,true,"333")
end

function SubObjClass:Print()
	print("SubObjClass 打印：", self.field1,self.field4,self.field5,self.field6)
	self.__super:Print()
	-- self.field7:Print()
	print(self.field7.a)
end

function TestType()
	local objClass = new(ObjClass,2,"3",true)
	objClass:Print()
end

function TestSuper()
	print("--------------父类测试----------")
	local SubObjClass = new(SubObjClass,42,"5",true)
	SubObjClass:Print()

	local field1 = SubObjClass.field1
	local private = SubObjClass._private
end

-- 创建ObjClass
local obj = new(ObjClass,11,true,"33")
obj:Print()
local subObj = new(SubObjClass,44,"55",true,{a=1})
subObj:Print()

subObj.field1 = 11111
print(subObj.field1)
-- subObj.field1 = "1111"

print("---------------类型测试结束---------------")


