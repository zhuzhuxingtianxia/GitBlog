# 构建聊天机器人

在开始之前请先配置好Langsmith和OpenAi的环境变量。
聊天模型本身没有任何状态存储的。
```
# 简单的直接使用ChatModel模型
def simple_chat():
    model = init_chat_model("gpt-4o-mini", model_provider="openai")
    response = model.invoke([HumanMessage(content="Hi! I'm Bob")])
    print(response.content)
    response = model.invoke([HumanMessage(content="What's my name?")])
    print(response.content)
```

返回打印结果如下：
```
Hi Bob! How can I assist you today?
I'm sorry, but I don't know your name. You haven't mentioned it yet. How can I help you today?
```
可以看到，它没有将之前的对话转化为上下文，并且无法回答问题。 这会导致糟糕的聊天机器人体验！

为了解决这个问题，我们需要将整个对话历史传递到模型中。如下：
```
def simple_chat_history():
    model = init_chat_model("gpt-4o-mini", model_provider="openai")
    response = model.invoke(
        [
            HumanMessage(content="Hi! I'm Bob"),
            AIMessage(content="Hello Bob! How can I assist you today?"),
            HumanMessage(content="What's my name?"),
        ]
    )
    print(response.content)
```
则结果是`Your name is Bob! How can I help you today?`。

现在我们得到了很好的回应！这是支撑聊天机器人进行对话交互能力的基本思想。且聊天模型对输入大小有最大限制，因此[管理聊天历史记录](https://langchain.cadn.net.cn/python/docs/concepts/chat_history/index.html)并根据需要对其进行修剪以避免超出上下文窗口非常重要。

## 消息持久化
[LangGraph](https://langchain-ai.github.io/langgraph/)实现了一个内置的持久层，使其成为支持多个对话轮次的聊天应用程序的理想选择。
```
pip install langgraph
```
LangGraph带有一个简单的[内存检查点](https://langchain-ai.github.io/langgraph/concepts/persistence/)程序，如下：
```
def chat_with_graph():
    workflow = StateGraph(state_schema=MessagesState)
    # 添加单个节点到Graph
    workflow.add_edge(START, "model")
    workflow.add_node("model", call_model)
    # 将Graph添加到内存中
    memory = MemorySaver()
    app = workflow.compile(checkpointer=memory)
    # 传递到runnable中，此配置包含的信息不直接属于input，但很重要。它使单个应用程序支持多个对话线程(不同thread_id不同对话)
    config = RunnableConfig(configurable={"thread_id": "abc123"})

    query = "Hi! I'm Bob."
    input_messages = [HumanMessage(query)]
    output = app.invoke({"messages": input_messages}, config)
    output["messages"][-1].pretty_print()
    
    query = "What's my name?"
    input_messages = [HumanMessage(query)]
    output = app.invoke({"messages": input_messages}, config)
    output["messages"][-1].pretty_print()
    # 打印完整历史
    for i, msg in enumerate(output["messages"]):
        print(f"{i + 1}. {msg.type}: {msg.content}")
```

打印输出：
```
======== Ai Message =========

Hi, Bob! How can I assist you today?

======== Ai Message =========

Your name is Bob! How can I help you today?
1. human: Hi! I'm Bob.
2. ai: Hi Bob! How can I assist you today?
3. human: What's my name?
4. ai: Your name is Bob! How can I help you today?
```

由于`MemorySaver`是加载到内存中的，所以采用连续执行的方式。重新执行函数，内存会被释放。
可采用数据库或文件储存代替内存存储。

在同一内存中使用不同`thread_id`则视为两个聊天窗口。

异步调用则需要修改`call_model`:
```
async def call_model(state: MessagesState):
    response = await model.ainvoke(state["messages"])
    return {"messages": response}
```
调用也需要使用`await`修饰,例如：`output = await app.ainvoke({"messages": input_messages}, config)`。

## 提示模板



