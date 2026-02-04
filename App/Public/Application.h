//
// Created by Caesar on 2025/12/2.
//

#ifndef QTUIDEMO_APPLICATION_H
#define QTUIDEMO_APPLICATION_H


class Application {
public:
    explicit Application(int argc, char *argv[]);
    ~Application();
    int execute();

private:
    void initialize();
    void cleanup();
    int argc_;
    char **argv_;
};

#endif //QTUIDEMO_APPLICATION_H