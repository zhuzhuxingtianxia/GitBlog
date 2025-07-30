# 构建Agent代理
agent代理通常是通过工具调用[too-calling](https://python.langchain.com/docs/concepts/tool_calling/)来实现。

## 端到端代理
我们使用[Tavily](https://www.tavily.com/)作为构建的搜索引擎。Langchain中对应包`langchain-tavily`。
安装依赖库：
```
pip install langchain_tavily
```
然后到[Tavily](https://www.tavily.com/)官网注册账户获取密钥，将密钥配置到环境变量`TAVILY_API_KEY`中。
`langchain-anthropic`是另一个ai框架，可到[Anthropic](https://docs.anthropic.com/zh-CN/docs/get-started)官网注册账户获取密钥,将密钥配置到环境变量`ANTHROPIC_API_KEY`中。但很不幸**Anthropic claude**不支持国内用户登录使用其API。
我们依然使用`openai`的`gpt-4o-mini`模型。

以下代码展示了一个完整的智能代理，使用LLM决定调用的工具。它配备了通用搜索工具，并具有对话记忆功能 - 可以作为多轮聊天机器人使用。

```
from langchain_tavily import TavilySearch
from langchain.chat_models import init_chat_model
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent

# 搜索引擎工具
search = TavilySearch(max_results=2)
# AI聊天模型
model = init_chat_model("gpt-4.1-nano", model_provider="openai")
# 创建智能体存储用于记忆
memory = MemorySaver()
tools = [search]
# create_react_agent 内部调用.bind_tools方法
agent_executor = create_react_agent(model, tools, checkpointer=memory)
# 代理配置
config = {"configurable": {"thread_id": "abc123"}}
# 输入消息
input_message = {
    "role": "user",
    "content": "Hi, 我是Bob, 我生活在上海.",
}
# 或
# input_message = HumanMessage(content="Hi, 我是Bob, 我生活在上海.")
# 使用代理，流输出
for step in agent_executor.stream(
    {"messages": [input_message]}, config, stream_mode="values"
):
    step["messages"][-1].pretty_print()

# 追加消息，验证记忆功能
input_message = {
    "role": "user",
    "content": "我生活的地方天气怎么样?",
}
# 流式输出消息, 将使用Tool Calls调用tavily_search工具搜索
for step in agent_executor.stream(
    {"messages": [input_message]}, config, stream_mode="values"
):
    step["messages"][-1].pretty_print()
    
# 流式输出token令牌
for step, metadata in agent_executor.stream(
    {"messages": [input_message]}, config=config, stream_mode="messages"
):
    if metadata["langgraph_node"] == "agent" and (text := step.text()):
        print(text, end="|")
```

python3.11也可使用.astream_events流回token令牌,
```
async for event in agent_executor.astream_events(
    {"messages": [HumanMessage(content="上海的天气怎么样？")]}
):
    kind = event["event"]
    if kind == "on_chain_start":
        if event["name"] == "Agent":
        # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
            print(f"Starting agent: {event['name']} with input: {event['data'].get('input')}")
    elif kind == "on_chain_end":
        if event["name"] == "Agent":
            # Was assigned when creating the agent with `.with_config({"run_name": "Agent"})`
            print()
            print("--")
            print(f"Done agent: {event['name']} with output: {event['data'].get('output')['output']}")
    if kind == "on_chat_model_stream":
        content = event["data"]["chunk"].content
        if content:
            # Empty content in the context of OpenAI means
            # that the model is asking for a tool to be invoked.
            # So we only print non-empty content
            print(content, end="|")
    elif kind == "on_tool_start":
        print("--")
        print(f"Starting tool: {event['name']} with inputs: {event['data'].get('input')}")
    elif kind == "on_tool_end":
        print(f"Done tool: {event['name']}")
        print(f"Tool output was: {event['data'].get('output')}")
        print("--")
```
打印结果如下：

```
--
Starting tool: tavily_search with inputs: {'query': '上海的天气'}
Done tool: tavily_search
Tool output was: content="{'error': ClientConnectorCertificateError(ConnectionKey(host='api.tavily.com', port=443, is_ssl=True, ssl=True, proxy=None, proxy_auth=None, proxy_headers_hash=None), SSLCertVerificationError(1, '[SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1020)'))}" name='tavily_search' tool_call_id='call_XB5wk7GyApp8Ncn2PELV7w1j'
--
我|目前|无法|直接|获取|上海|的|实时|天气|信息|。|建议|您|可以|通过|天气|预|报|网站|或|手机|天气|应用|查询|最新|的|天气|情况|。|需要|我|帮|忙|查|找|一些|推荐|的|天气|查询|渠道|吗|？|
```
不知道为什么使用`.astream_events`调用工具一直报错。
