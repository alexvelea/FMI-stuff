package message.menu;

import java.io.ObjectOutputStream;
import message.BaseMessage;

class Request extends BaseMessage {
    @Override
    public BaseMessage onNetworkMessage() {
        System.out.println("Someone requested a menu <3. Isn't that nice?");
        return this.makeResponse();
    }

    @Override
    public void serialise(ObjectOutputStream out) throws java.io.IOException {
        out.writeObject(this);
    }

    public BaseMessage makeResponse() {
        Response response = new Response();
        response.ensureData();
        return response;
    }

//    @Override
//    public String toString() {
//        return "Foo [coolValue=" + coolValue + "]";
//    }
}
