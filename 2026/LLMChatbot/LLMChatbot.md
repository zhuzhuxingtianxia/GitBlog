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

[提示模板](https://langchain.cadn.net.cn/python/docs/concepts/prompt_templates/index.html)有助于将原始用户信息转换为LLM可以使用的格式.

修改上面的例子，使用`ChatPromptTemplate`提示模版调用模型，并利用`MessagesPlaceholder`以传入所有消息：
```
# 调用模型
def call_model_prompt(state: MessagesState):
    model = init_chat_model("gpt-4o-mini", model_provider="openai")
    # 自定义系统消息提示模版，并利用MessagesPlaceholder以传入所有消息
    prompt_template = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                # You talk like a pirate. Answer all questions to the best of your ability.
                "你说话像一个海盗。尽你所能用中文回答所有问题。",
            ),
            MessagesPlaceholder(variable_name="messages"),
        ]
    )
    prompt = prompt_template.invoke(state)
    response = model.invoke(prompt)
    return {"messages": response}
```

调用`chat_with_graph`时，将`workflow.add_node("model", call_model)`改为`workflow.add_node("model", call_model_prompt)`，执行`chat_with_graph()`
我们得到了如下的回答：
```
================ Ai Message ====================

Ahoy，吉姆！欢迎登船！有何指令或者问题，尽管问吧！☠️⚓️
================ Ai Message ====================

你叫吉姆，海盗的朋友！有什么需要我这位老海盗帮忙的，尽管说吧！☠️🏴‍☠️
1. human: Hi! I'm Jim.
2. ai: Ahoy，吉姆！欢迎登船！有何指令或者问题，尽管问吧！☠️⚓️
3. human: What's my name?
4. ai: 你叫吉姆，海盗的朋友！有什么需要我这位老海盗帮忙的，尽管说吧！☠️🏴‍☠️

```

下面我们修改提示词，并添加输入变量`language`到提示符中：
```
prompt_template = ChatPromptTemplate.from_messages(
    [
        (
            "system",
            # You are a helpful assistant. Answer all questions to the best of your ability in {language}.
            "你是个乐于助人的助手。尽你所能用{language}回答所有问题。",
        ),
        MessagesPlaceholder(variable_name="messages"),
    ]
)
```
我们现在就需要两个输入参数`messages`和`language`。所以我们就需要扩展`state_schema`:
```
class State(TypedDict):
    messages: Annotated[Sequence[BaseMessage], add_messages]
    language: str
```

然后我们需要修改`MessagesState`为`State`, 并添加输入参数`language`字段，代码修改如下：
```
def call_model_prompt(state: State):
    model = init_chat_model("gpt-4o-mini", model_provider="openai")
    # 自定义系统消息提示模版，并利用MessagesPlaceholder以传入所有消息
    prompt_template = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                # You are a helpful assistant. Answer all questions to the best of your ability in {language}.
                "你是个乐于助人的助手。尽你所能用{language}回答所有问题。",
            ),
            MessagesPlaceholder(variable_name="messages"),
        ]
    )
    prompt = prompt_template.invoke(state)
    response = model.invoke(prompt)
    return {"messages": [response]}

def chat_with_graph():
    workflow = StateGraph(state_schema=State)
    # 添加单个节点到Graph
    workflow.add_edge(START, "model")
    workflow.add_node("model", call_model_prompt)
    workflow.add_edge("model", END)
    # 将Graph添加到内存中
    memory = MemorySaver()
    app = workflow.compile(checkpointer=memory)
    # 传递到runnable中，此配置包含的信息不直接属于input，但很重要。它使单个应用程序支持多个对话线程(不同thread_id不同对话)
    config = RunnableConfig(configurable={"thread_id": "abc123"})

    query = "Hi! I'm Jim."
    language = "zh"
    input_messages = [HumanMessage(query)]
    output = app.invoke(
        {"messages": input_messages, "language": language},
        config
    )
    output["messages"][-1].pretty_print()

    query = "What's my name?"
    input_messages = [HumanMessage(query)]
    output = app.invoke(
        {"messages": input_messages, "language": language},
        config
    )
    output["messages"][-1].pretty_print()
    # 打印完整历史
    for i, msg in enumerate(output["messages"]):
        print(f"{i + 1}. {msg.type}: {msg.content}")
```

## 管理对话历史
构建聊天机器人时需要管理对话历史, 否则消息列表无限增长，将使LLM上下文溢出。因此添加一个限制传递的消息大小的步骤是很重要的。

LangChain内置了[管理消息列表](https://python.langchain.com/docs/how_to/#messages)工具助手.使用修剪器`trim_messages`来减少我们向模型发送的消息数量。
修剪器允许我们指定我们想要保留多少个令牌,以及其他参数,例如如果我们想始终保留系统消息以及是否允许部分消息:
```
def chat_trim_messages():
    model = init_chat_model("gpt-4o-mini", model_provider="openai")
    trimmer = trim_messages(
        max_tokens=65,
        strategy="last",
        token_counter=model,
        include_system=True,
        allow_partial=False,
        start_on="human",
    )

    messages = [
        SystemMessage(content="you're a good assistant"),
        HumanMessage(content="hi! I'm bob"),
        AIMessage(content="hi!"),
        HumanMessage(content="I like vanilla ice cream"),
        AIMessage(content="nice"),
        HumanMessage(content="whats 2 + 2"),
        AIMessage(content="4"),
        HumanMessage(content="thanks"),
        AIMessage(content="no problem!"),
        HumanMessage(content="having fun?"),
        AIMessage(content="yes!"),
    ]

    output = trimmer.invoke(messages)
    # 打印完整历史
    for i, msg in enumerate(output):
        print(f"{i + 1}. {msg.type}: {msg.content}")
```